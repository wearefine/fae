module Fae
  class Video < ActiveRecord::Base

    include Fae::BaseModelConcern
    include Fae::VideoConcern

    ERROR_STATUSES = %w(errored cancelled timed_out).freeze
    PASSTHROUGH_SEPARATOR = '^'.freeze
    PRODUCTION_MUX_ENVIRONMENTS = %w(production prod).freeze
    ORPHAN_GRACE_PERIOD = 24.hours

    belongs_to :videoable, polymorphic: true, touch: true, optional: true

    validate :video_exists

    # Uploads always go to this deployment's Mux environment, so a new upload_id means this environment owns the asset.
    before_save :stamp_mux_environment, if: -> { upload_id_changed? && upload_id.present? }
    # Mux webhooks can arrive before the parent form is saved, so pull the current state on first save.
    before_save :sync_with_mux, if: -> { upload_id_changed? && upload_id.present? && playback_id.blank? }
    after_commit :soft_delete_mux_asset, on: :destroy
    after_commit :claim_mux_asset, on: [:create, :update], if: -> { previous_changes.key?('asset_id') && asset_id.present? }

    # Each deployment has its own isolated Mux environment, but databases are copied between deployments
    # (e.g. prod -> dev), so a row may point at an asset this deployment's tokens can't manage.
    def self.mux_environment
      Fae.mux_environment.presence || Rails.env
    end

    def self.mux_marker(tag)
      "#{tag}-#{mux_environment}#{PASSTHROUGH_SEPARATOR}"
    end

    # Deletes assets in this deployment's Mux environment that no Fae::Video row references, e.g. dev uploads whose
    # rows were overwritten by a prod -> dev database pull. Only assets this app uploaded (per their passthrough) and
    # older than the grace period are touched. Returns the assets that were (or, in a dry run, would be) deleted.
    def self.purge_orphaned_mux_assets(dry_run: true, older_than: ORPHAN_GRACE_PERIOD)
      if Fae.mux_environment.blank? || PRODUCTION_MUX_ENVIRONMENTS.include?(Fae.mux_environment.to_s.downcase)
        raise ArgumentError, "Refusing to purge Mux assets: MUX_ENVIRONMENT is #{Fae.mux_environment.inspect}. Set it to a non-production environment name."
      end

      referenced_asset_ids = where.not(asset_id: nil).pluck(:asset_id).to_set
      referenced_upload_ids = where.not(upload_id: nil).pluck(:upload_id).to_set
      source_marker = mux_marker('source')
      cutoff = older_than.ago.to_i
      assets_api = MuxRuby::AssetsApi.new

      orphans = []
      cursor = nil
      loop do
        response = assets_api.list_assets({ limit: 100, cursor: cursor }.compact)
        Array(response.data).each do |asset|
          next if referenced_asset_ids.include?(asset.id) || referenced_upload_ids.include?(asset.upload_id)
          next unless asset.passthrough.to_s.start_with?(source_marker)
          next if asset.created_at.to_i > cutoff
          orphans << asset
        end
        cursor = response.next_cursor
        break if cursor.blank? || Array(response.data).empty?
      end

      orphans.each { |asset| assets_api.delete_asset(asset.id) } unless dry_run
      orphans
    end

    # Uploads start out orphaned so abandoned forms leave a trace in Mux; the tag is cleared once a record owns the asset.
    def self.create_mux_upload(cors_origin)
      upload_request = MuxRuby::CreateUploadRequest.new(
        cors_origin: cors_origin,
        new_asset_settings: MuxRuby::CreateAssetRequest.new(
          playback_policies: [MuxRuby::PlaybackPolicy::PUBLIC],
          passthrough: mux_marker('source') + mux_marker('orphaned')
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

    def owned_by_current_mux_environment?
      mux_environment.present? && mux_environment == self.class.mux_environment
    end

    # Only the owning deployment receives this asset's webhooks, so other deployments shouldn't wait for one.
    def awaiting_mux_webhook?
      processing? && owned_by_current_mux_environment?
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

    # A copy of this video for a cloned record (see Fae::Cloneable). The copy gets its own Mux asset, copied from this
    # one, so deleting either video leaves the other playable. Returns nil if there's nothing to copy yet.
    def dup_for_clone
      return if asset_id.blank?

      copy = dup
      # The upload belongs to the original: webhooks for it must only find the original, and a new upload_id would
      # also stamp the copy as owned by this environment
      copy.upload_id = nil

      # Another environment's asset can't be copied with this environment's tokens, but this environment never
      # changes it either, so the copy can share it
      return copy unless owned_by_current_mux_environment?

      # Mux can only copy a finished asset; a video that's still processing isn't cloned
      return unless ready?

      asset = MuxRuby::AssetsApi.new.create_asset(
        MuxRuby::CreateAssetRequest.new(
          inputs: [MuxRuby::InputSettings.new(url: "mux://assets/#{asset_id}")],
          playback_policies: [MuxRuby::PlaybackPolicy::PUBLIC],
          passthrough: self.class.mux_marker('source')
        )
      ).data
      copy.assign_mux_asset(asset)
      # The new asset reports these once it's ready; until then show the source's
      copy.duration ||= duration
      copy.aspect_ratio ||= aspect_ratio
      copy
    rescue MuxRuby::ApiError => e
      Rails.logger.error("Fae::Video could not copy Mux asset #{asset_id}: #{e.message}")
      nil
    end

    # Pulls the upload's current state from Mux. Also used for uploads that aren't saved yet (see VideosController#upload_status).
    def sync_with_mux
      upload = MuxRuby::DirectUploadsApi.new.get_direct_upload(upload_id).data
      self.status = upload.status
      assign_mux_asset(MuxRuby::AssetsApi.new.get_asset(upload.asset_id).data) if upload.asset_id.present?
    rescue MuxRuby::ApiError => e
      Rails.logger.error("Fae::Video could not sync upload #{upload_id} with Mux: #{e.message}")
    end

    def remove_mux_asset!
      soft_delete_mux_asset
      clear_mux_attributes!
    end

    def clear_mux_attributes!
      assign_attributes(upload_id: nil, asset_id: nil, playback_id: nil, mux_environment: nil, status: nil, duration: nil, aspect_ratio: nil, title: nil)
      save(validate: false)
    end

    private

    def video_exists
      errors.add(:upload_id, "Video can't be empty") if required && upload_id.blank?
    end

    def stamp_mux_environment
      self.mux_environment = self.class.mux_environment
    end


    # The Mux asset is kept; its passthrough is tagged so deleted videos can be found and purged later.
    def soft_delete_mux_asset
      return if asset_id.blank?
      update_mux_passthrough { |passthrough| passthrough + self.class.mux_marker('deleted') }
    end

    def claim_mux_asset
      update_mux_passthrough { |passthrough| passthrough.sub(self.class.mux_marker('orphaned'), '') }
    end

    # Assets owned by another deployment's Mux environment are left alone; only this row changes.
    def update_mux_passthrough
      return unless owned_by_current_mux_environment?

      assets_api = MuxRuby::AssetsApi.new
      passthrough = assets_api.get_asset(asset_id).data.passthrough.to_s
      updated = yield(passthrough)
      assets_api.update_asset(asset_id, MuxRuby::UpdateAssetRequest.new(passthrough: updated)) unless updated == passthrough
    rescue MuxRuby::NotFoundError
      nil
    rescue MuxRuby::ApiError => e
      Rails.logger.error("Fae::Video could not update Mux asset #{asset_id}: #{e.message}")
    end

  end
end