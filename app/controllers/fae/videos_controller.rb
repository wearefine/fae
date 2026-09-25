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

    # ajax action, polled while a video is processing
    def status
      render_status
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

    def render_status
      html = render_to_string(partial: 'fae/videos/video_preview', formats: [:html], locals: { video: @video })
      render json: { processing: @video.processing?, html: html }
    end

  end
end