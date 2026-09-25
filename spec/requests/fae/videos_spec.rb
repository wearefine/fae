require 'rails_helper'

describe 'videos ajax actions' do

  let(:location) { Location.create!(name: 'HQ') }
  let(:video) { location.create_video }

  before do
    user_login
    allow_any_instance_of(Fae::Video).to receive(:sync_with_mux)
  end

  describe 'videos#attach_upload' do
    it 'should save the upload to the record so webhooks can find it' do
      post fae.attach_video_upload_path(video.id), params: { upload_id: 'upload123', title: 'clip.mp4' }

      json = JSON.parse(response.body)
      expect(json['processing']).to eq(true)
      expect(json['html']).to include(I18n.t('fae.videos.processing'))
      expect(video.reload.upload_id).to eq('upload123')
      expect(video.title).to eq('clip.mp4')
    end
  end

  describe 'videos#status' do
    it 'should render the preview once the webhook marks the video ready' do
      video.update_columns(upload_id: 'upload123', asset_id: 'asset123')
      Fae::Video.process_mux_event('type' => 'video.asset.ready', 'data' => { 'id' => 'asset123', 'status' => 'ready', 'playback_ids' => [{ 'id' => 'play123', 'policy' => 'public' }] })

      get fae.video_status_path(video.id)

      json = JSON.parse(response.body)
      expect(json['processing']).to eq(false)
      expect(json['html']).to include('js-video-modal')
      expect(json['html']).to include('image.mux.com/play123')
    end
  end

end
