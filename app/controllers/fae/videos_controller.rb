module Fae
  class VideosController < ApplicationController
    before_action :set_video, only: [:attach_upload, :status, :delete_video]

    # ajax action
    #
    # Called by <mux-uploader> to get a direct upload URL once a file is selected.
    def create_upload
      upload = Fae::Video.create_mux_upload(request.base_url)
      render json: { url: upload.url, id: upload.id }
    rescue MuxRuby::ApiError => e
      Rails.logger.error("Mux API error: #{e.message}")
      render json: { error: 'Unable to create a Mux upload' }, status: :unprocessable_entity
    end

    # ajax action
    #
    # Saves a finished upload to an existing record right away so Mux webhooks can find it.
    def attach_upload
      @video.update!(upload_id: params.require(:upload_id), title: params[:title])
      render_status
    end

    # ajax action
    #
    # Like attach_upload, for a saved record whose video row doesn't exist yet (e.g. a nested form or flex component,
    # where build_assets only builds the video in memory). Creates the row so the upload can be tracked right away.
    def attach_new_upload
      owner = video_owner
      return head :unprocessable_entity if owner.blank?

      attached_as = params[:attached_as].to_s
      @video = owner.public_send(attached_as) || owner.public_send("build_#{attached_as}")
      @video.update!(upload_id: params.require(:upload_id), title: params[:title])
      render_status
    end

    # ajax action, polled while a video is processing
    def status
      render_status
    end

    # ajax action, polled while a video is processing on a record that hasn't been saved yet (e.g. a new nested item)
    #
    # Nothing is saved: the upload is attached when the form is saved. This reads its state straight from Mux.
    def upload_status
      @video = Fae::Video.new(upload_id: params.require(:upload_id), title: params[:title], mux_environment: Fae::Video.mux_environment)
      @video.sync_with_mux
      # No status means Mux couldn't be reached (sync_with_mux logs why); stop polling instead of retrying forever
      render_status(processing: @video.status.present? && @video.awaiting_mux_webhook?)
    end

    # ajax delete action
    #
    # Like ImagesController#delete_image, the record is kept so re-uploading from the same form still works.
    def delete_video
      @video.remove_mux_asset!
      head :ok
    end

    private

    def set_video
      @video = Fae::Video.find(params[:id])
    end

    # Only has_one Fae::Video associations (has_fae_video) can be attached through attach_new_upload
    def video_owner
      klass = params[:owner_type].to_s.safe_constantize
      return unless klass.is_a?(Class) && klass < ActiveRecord::Base

      reflection = klass.reflect_on_association(params[:attached_as].to_s)
      return unless reflection && reflection.macro == :has_one && reflection.klass == Fae::Video

      klass.find_by(id: params[:owner_id])
    end

    def render_status(processing: @video.awaiting_mux_webhook?)
      html = render_to_string(partial: 'fae/videos/video_preview', formats: [:html], locals: { video: @video })
      json = { processing: processing, html: html }
      if @video.persisted?
        json.merge!(id: @video.id, status_url: fae.video_status_path(@video), attach_url: fae.attach_video_upload_path(@video))
      end
      render json: json
    end

  end
end