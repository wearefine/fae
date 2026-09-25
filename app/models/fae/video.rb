module Fae
  class Video < ActiveRecord::Base

    include Fae::BaseModelConcern
    include Fae::VideoConcern

    ERROR_STATUSES = %w(errored cancelled timed_out).freeze
    PASSTHROUGH_SEPARATOR = '^'.freeze

    belongs_to :videoable, polymorphic: true, touch: true, optional: true

    validate :video_exists

    # Mux webhooks can arrive before the parent form is saved, so pull the current state on first save.
    before_save :sync_with_mux, if: -> { upload_id_changed? && upload_id.present? && playback_id.blank? }
    after_commit :soft_delete_mux_asset, on: :destroy

    def self.create_mux_upload(cors_origin)
      upload_request = MuxRuby::CreateUploadRequest.new(
        cors_origin: cors_origin,
        new_asset_settings: MuxRuby::CreateAssetRequest.new(
          playback_policies: [MuxRuby::PlaybackPolicy::PUBLIC],
          passthrough: "source-#{Rails.env}#{PASSTHROUGH_SEPARATOR}"
        )
      )
      MuxRuby::DirectUploadsApi.new.create_direct_upload(upload_request).data
    end

    # https://www.mux.com/docs/core/webhooks
    def self.process_mux_event(event)
      data = event['data'] || {}

      case event['type']
      when 'video.upload.asset_created'
        video = find_for_mux_upload(data)
        video.update!(asset_id: data['asset_id'], status: 'preparing') if video && video.asset_id.blank?
      when 'video.upload.errored', 'video.upload.cancelled'
        find_for_mux_upload(data).try(:update!, status: data['status'] || 'errored')
      when 'video.asset.ready', 'video.asset.errored'
        video = find_for_mux_asset(data)
        return if video.blank?
        video.assign_mux_asset(data)
        video.save!
      when 'video.asset.deleted'
        find_for_mux_asset(data).try(:clear_mux_attributes!)
      end
    end

    def self.find_for_mux_upload(upload)
      find_by(upload_id: upload['id']) if upload['id'].present?
    end

    def self.find_for_mux_asset(asset)
      video = find_by(asset_id: asset['id']) if asset['id'].present?
      video ||= find_by(upload_id: asset['upload_id']) if asset['upload_id'].present?
      video
    end

    def readonly?
      false
    end

    def uploaded?
      upload_id.present? || asset_id.present?
    end

    def ready?
      status == 'ready' && playback_id.present?
    end

    def errored?
      ERROR_STATUSES.include?(status)
    end

    def processing?
      uploaded? && !ready? && !errored?
    end

    def thumbnail_url(width: 640)
      "https://image.mux.com/#{playback_id}/thumbnail.jpg?width=#{width}" if playback_id.present?
    end

    # Accepts a MuxRuby::Asset or a webhook's asset hash.
    def assign_mux_asset(asset)
      asset = asset.to_hash.with_indifferent_access
      public_playback = Array(asset[:playback_ids]).find { |playback| playback[:policy].to_s == 'public' }

      assign_attributes(
        asset_id: asset[:id],
        status: asset[:status],
        playback_id: public_playback.try(:[], :id),
        duration: asset[:duration],
        aspect_ratio: asset[:aspect_ratio]
      )
    end

    def remove_mux_asset!
      soft_delete_mux_asset
      clear_mux_attributes!
    end

    def clear_mux_attributes!
      assign_attributes(upload_id: nil, asset_id: nil, playback_id: nil, status: nil, duration: nil, aspect_ratio: nil, title: nil)
      save(validate: false)
    end

    private

    def video_exists
      errors.add(:upload_id, "Video can't be empty") if required && upload_id.blank?
    end

    def sync_with_mux
      upload = MuxRuby::DirectUploadsApi.new.get_direct_upload(upload_id).data
      self.status = upload.status
      assign_mux_asset(MuxRuby::AssetsApi.new.get_asset(upload.asset_id).data) if upload.asset_id.present?
    rescue MuxRuby::ApiError => e
      Rails.logger.error("Fae::Video could not sync upload #{upload_id} with Mux: #{e.message}")
    end

    # The Mux asset is kept; its passthrough is tagged so deleted videos can be found and purged later.
    def soft_delete_mux_asset
      return if asset_id.blank?
      assets_api = MuxRuby::AssetsApi.new
      passthrough = assets_api.get_asset(asset_id).data.passthrough.to_s
      marker = "deleted-#{Rails.env}#{PASSTHROUGH_SEPARATOR}"
      assets_api.update_asset(asset_id, MuxRuby::UpdateAssetRequest.new(passthrough: passthrough + marker))
    rescue MuxRuby::NotFoundError
      nil
    rescue MuxRuby::ApiError => e
      Rails.logger.error("Fae::Video could not soft delete Mux asset #{asset_id}: #{e.message}")
    end

  end
end
