require 'rails_helper'

describe Fae::Video do

  let(:mux_asset) do
    {
      'id' => 'asset123',
      'upload_id' => 'upload123',
      'status' => 'ready',
      'duration' => 42.5,
      'aspect_ratio' => '16:9',
      'playback_ids' => [{ 'id' => 'signed456', 'policy' => 'signed' }, { 'id' => 'public789', 'policy' => 'public' }]
    }
  end

  before { allow_any_instance_of(Fae::Video).to receive(:claim_mux_asset) }

  describe 'concerns' do
    it 'should allow instance methods through Fae::VideoConcern' do
      video = FactoryGirl.build_stubbed(:fae_video)
      expect(video.instance_says_what).to eq('Fae::Video instance: what?')
    end
  end

  describe 'has_fae_video' do
    it 'should attach a Fae::Video to the parent' do
      location = Location.create!(name: 'HQ')
      location.create_video(asset_id: 'asset123')
      expect(location.reload.video).to be_a(Fae::Video)
      expect(location.video.attached_as).to eq('video')
    end
  end

  describe 'validations' do
    it 'should require an upload when required' do
      video = FactoryGirl.build(:fae_video, required: true)
      expect(video).not_to be_valid
      expect(video.errors[:upload_id]).to be_present
    end
  end

  describe '#assign_mux_asset' do
    it 'should use the public playback id' do
      video = FactoryGirl.build(:fae_video)
      video.assign_mux_asset(mux_asset)

      expect(video.asset_id).to eq('asset123')
      expect(video.playback_id).to eq('public789')
      expect(video.duration).to eq(42.5)
      expect(video.aspect_ratio).to eq('16:9')
      expect(video).to be_ready
    end
  end

  describe '.create_mux_upload' do
    it 'should tag the new asset with its source environment as orphaned' do
      uploads_api = instance_double(MuxRuby::DirectUploadsApi)
      allow(MuxRuby::DirectUploadsApi).to receive(:new).and_return(uploads_api)
      expect(uploads_api).to receive(:create_direct_upload) do |request|
        expect(request.cors_origin).to eq('http://example.com')
        expect(request.new_asset_settings.passthrough).to eq("source-#{Rails.env}^orphaned-#{Rails.env}^")
        double(data: double(id: 'upload123', url: 'https://upload.example'))
      end

      Fae::Video.create_mux_upload('http://example.com')
    end
  end

  describe '#remove_mux_asset!' do
    let(:assets_api) { instance_double(MuxRuby::AssetsApi) }
    let(:video) { FactoryGirl.create(:fae_video, asset_id: 'asset123', playback_id: 'public789', status: 'ready') }

    before do
      allow(MuxRuby::AssetsApi).to receive(:new).and_return(assets_api)
      allow(assets_api).to receive(:get_asset).with('asset123')
        .and_return(double(data: double(passthrough: 'source-staging^deleted-staging^')))
    end

    it 'should append a deleted marker to the passthrough instead of deleting the Mux asset' do
      expect(assets_api).not_to receive(:delete_asset)
      expect(assets_api).to receive(:update_asset) do |asset_id, request|
        expect(asset_id).to eq('asset123')
        expect(request.passthrough).to eq("source-staging^deleted-staging^deleted-#{Rails.env}^")
      end

      video.remove_mux_asset!

      expect(video.reload).not_to be_uploaded
      expect(video.playback_id).to be_nil
    end

    it 'should still clear the video if Mux fails' do
      allow(assets_api).to receive(:update_asset).and_raise(MuxRuby::ApiError.new('boom'))
      video.remove_mux_asset!
      expect(video.reload).not_to be_uploaded
    end
  end

  describe 'claiming the Mux asset' do
    let(:assets_api) { instance_double(MuxRuby::AssetsApi) }
    let(:video) { FactoryGirl.create(:fae_video, upload_id: 'upload123') }

    before do
      allow_any_instance_of(Fae::Video).to receive(:claim_mux_asset).and_call_original
      allow_any_instance_of(Fae::Video).to receive(:sync_with_mux)
      allow(MuxRuby::AssetsApi).to receive(:new).and_return(assets_api)
    end

    it 'should remove the orphaned tag once a record has the asset' do
      video
      allow(assets_api).to receive(:get_asset).with('assetABC')
        .and_return(double(data: double(passthrough: "source-#{Rails.env}^orphaned-#{Rails.env}^")))
      expect(assets_api).to receive(:update_asset) do |asset_id, request|
        expect(asset_id).to eq('assetABC')
        expect(request.passthrough).to eq("source-#{Rails.env}^")
      end

      Fae::Video.process_mux_event('type' => 'video.upload.asset_created', 'data' => { 'id' => 'upload123', 'asset_id' => 'assetABC' })
    end

    it 'should leave assets without the orphaned tag alone' do
      allow(assets_api).to receive(:get_asset).and_return(double(data: double(passthrough: "source-#{Rails.env}^")))
      expect(assets_api).not_to receive(:update_asset)

      video.update!(asset_id: 'assetABC')
    end

    it 'should not claim when the asset is cleared' do
      video.update_column(:asset_id, 'assetABC')
      expect(assets_api).not_to receive(:get_asset)

      video.clear_mux_attributes!
    end
  end

  describe '.process_mux_event' do
    let!(:video) { FactoryGirl.create(:fae_video, asset_id: 'asset123') }

    it 'should store the asset id when the upload creates an asset' do
      waiting = FactoryGirl.create(:fae_video, asset_id: nil)
      waiting.update_column(:upload_id, 'uploadABC')

      Fae::Video.process_mux_event('type' => 'video.upload.asset_created', 'data' => { 'id' => 'uploadABC', 'asset_id' => 'assetABC' })

      expect(waiting.reload.asset_id).to eq('assetABC')
      expect(waiting.status).to eq('preparing')
    end

    it 'should mark the video ready' do
      Fae::Video.process_mux_event('type' => 'video.asset.ready', 'data' => mux_asset)
      expect(video.reload).to be_ready
      expect(video.playback_id).to eq('public789')
    end

    it 'should ignore events for unknown videos' do
      Fae::Video.process_mux_event('type' => 'video.asset.ready', 'data' => mux_asset.merge('id' => 'nope', 'upload_id' => 'nope'))
      expect(video.reload.playback_id).to be_nil
    end

    it 'should not match videos without an asset id when the payload has none' do
      FactoryGirl.create(:fae_video)
      Fae::Video.process_mux_event('type' => 'video.asset.ready', 'data' => mux_asset.merge('id' => nil, 'upload_id' => nil))
      expect(Fae::Video.where.not(playback_id: nil)).to be_empty
    end

    it 'should clear the video when the asset is deleted in Mux' do
      Fae::Video.process_mux_event('type' => 'video.asset.deleted', 'data' => { 'id' => 'asset123' })
      expect(video.reload.asset_id).to be_nil
      expect(video).not_to be_uploaded
    end
  end

end
