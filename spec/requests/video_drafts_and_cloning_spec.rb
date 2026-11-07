require 'rails_helper'

describe 'video uploads on models with draft support' do

  before { admin_login }

  def video_wrapper
    Nokogiri::HTML(response.body).at_css('.input.video.video')
  end

  # Same as every other saved record, so the field shows processing and the preview without saving the form
  it 'should attach uploads right away, like models without draft support' do
    beer = Beer.create!(name: 'Draft Beer', draft: true)

    get "/admin/beers/#{beer.id}/edit", params: { draft: true }

    expect(response.status).to eq(200)
    expect(video_wrapper['data-attach-url']).to eq(fae.attach_new_video_upload_path(owner_type: 'Beer', owner_id: beer.id, attached_as: 'video'))
  end

  it 'should poll and attach to an existing video' do
    allow_any_instance_of(Fae::Video).to receive(:sync_with_mux)
    beer = Beer.create!(name: 'Beer')
    video = beer.create_video!(upload_id: 'upload1', attached_as: 'video')

    get "/admin/beers/#{beer.id}/edit"

    expect(video_wrapper['data-status-url']).to eq(fae.video_status_path(video))
    expect(video_wrapper['data-attach-url']).to eq(fae.attach_video_upload_path(video))
  end

end

describe 'videos#upload_status' do

  let(:uploads_api) { instance_double(MuxRuby::DirectUploadsApi) }
  let(:assets_api) { instance_double(MuxRuby::AssetsApi) }

  before do
    admin_login
    allow(MuxRuby::DirectUploadsApi).to receive(:new).and_return(uploads_api)
    allow(MuxRuby::AssetsApi).to receive(:new).and_return(assets_api)
  end

  def upload_status
    expect { get fae.video_upload_status_path(upload_id: 'upload1', title: 'clip.mp4') }.not_to change(Fae::Video, :count)
    JSON.parse(response.body)
  end

  def preview
    Nokogiri::HTML(JSON.parse(response.body)['html'])
  end

  it 'should report a processing upload without saving anything' do
    allow(uploads_api).to receive(:get_direct_upload).with('upload1').and_return(double(data: double(status: 'asset_created', asset_id: 'asset1')))
    allow(assets_api).to receive(:get_asset).with('asset1').and_return(double(data: MuxRuby::Asset.new(id: 'asset1', status: 'preparing')))

    json = upload_status

    expect(json['processing']).to eq(true)
    expect(json).not_to have_key('id')
    expect(preview.at_css('.asset-actions.-video.js-video-processing .asset-title').text).to eq(I18n.t('fae.videos.processing'))
    # Not saved yet, so removing it just clears the field
    expect(preview.at_css('.js-video-upload-delete')).to be_present
    expect(preview.at_css('.js-video-delete')).to be_nil
  end

  it 'should render the preview once the asset is ready' do
    asset = MuxRuby::Asset.new(id: 'asset1', status: 'ready', duration: 10.2, aspect_ratio: '16:9',
                               playback_ids: [MuxRuby::PlaybackID.new(id: 'playback1', policy: 'public')])
    allow(uploads_api).to receive(:get_direct_upload).and_return(double(data: double(status: 'asset_created', asset_id: 'asset1')))
    allow(assets_api).to receive(:get_asset).and_return(double(data: asset))

    json = upload_status

    expect(json['processing']).to eq(false)
    expect(preview.at_css('img.js-video-modal')['data-playback-id']).to eq('playback1')
    expect(preview.at_css('.asset-title').text).to eq('clip.mp4 (0:10)')
  end

  it 'should stop polling if Mux cannot be reached' do
    allow(uploads_api).to receive(:get_direct_upload).and_raise(MuxRuby::ApiError.new('boom'))

    json = upload_status

    expect(json['processing']).to eq(false)
    expect(preview.at_css('.asset-title').text).to eq('clip.mp4')
    expect(preview.at_css('.js-video-processing')).to be_nil
  end

end

describe 'cloning videos' do

  let(:release) { FactoryBot.create(:release, name: 'Ima Release') }
  let(:assets_api) { instance_double(MuxRuby::AssetsApi) }
  let(:cloned_release) { Release.find_by_name('Ima Release-2') }

  before do
    admin_login
    allow(MuxRuby::AssetsApi).to receive(:new).and_return(assets_api)
    # claim_mux_asset checks the new asset's passthrough after it's saved
    allow(assets_api).to receive(:get_asset).and_return(double(data: double(passthrough: Fae::Video.mux_marker('source'))))
  end

  def create_video(attrs = {})
    Fae::Video.create!({
      videoable: release, attached_as: 'video', title: 'clip.mp4',
      upload_id: 'upload1', asset_id: 'asset1', playback_id: 'playback1', status: 'ready',
      duration: 12.5, aspect_ratio: '16:9', mux_environment: Fae::Video.mux_environment
    }.merge(attrs))
  end

  def clone_release
    post "/admin/releases", params: { from_existing: release.id }
    expect(cloned_release).to be_present
  end

  it 'should give the clone its own copy of the Mux asset' do
    video = create_video
    new_asset = MuxRuby::Asset.new(id: 'asset2', status: 'preparing', playback_ids: [MuxRuby::PlaybackID.new(id: 'playback2', policy: 'public')])
    expect(assets_api).to receive(:create_asset) do |request|
      expect(request.inputs.map(&:url)).to eq(['mux://assets/asset1'])
      expect(request.playback_policies).to eq([MuxRuby::PlaybackPolicy::PUBLIC])
      expect(request.passthrough).to eq(Fae::Video.mux_marker('source'))
      double(data: new_asset)
    end

    clone_release

    copy = cloned_release.video
    expect(copy.id).not_to eq(video.id)
    expect(copy.videoable).to eq(cloned_release)
    expect(copy.attributes.slice('asset_id', 'playback_id', 'status', 'upload_id', 'title', 'duration', 'aspect_ratio', 'attached_as'))
      .to eq('asset_id' => 'asset2', 'playback_id' => 'playback2', 'status' => 'preparing', 'upload_id' => nil,
             'title' => 'clip.mp4', 'duration' => 12.5, 'aspect_ratio' => '16:9', 'attached_as' => 'video')
    expect(copy.mux_environment).to eq(Fae::Video.mux_environment)
    expect(video.reload.asset_id).to eq('asset1')
  end

  it "should share the asset when it belongs to another environment, since this environment never changes it" do
    # As left by a prod -> dev database pull (saving an upload stamps this environment, so set it afterwards)
    create_video.update_column(:mux_environment, 'production')
    expect(assets_api).not_to receive(:create_asset)

    clone_release

    copy = cloned_release.video
    expect(copy.playback_id).to eq('playback1')
    expect(copy.asset_id).to eq('asset1')
    expect(copy.mux_environment).to eq('production')
    # A copied upload_id would stamp the copy as this environment's, letting it tag prod's asset as deleted
    expect(copy.upload_id).to be_nil
  end

  it 'should not clone a video that is still processing' do
    allow_any_instance_of(Fae::Video).to receive(:sync_with_mux)
    create_video(asset_id: 'asset1', playback_id: nil, status: 'preparing')
    expect(assets_api).not_to receive(:create_asset)

    clone_release

    expect(cloned_release.video).to be_nil
  end

  it 'should still clone the record if Mux refuses to copy the asset' do
    create_video
    allow(assets_api).to receive(:create_asset).and_raise(MuxRuby::ApiError.new('boom'))

    clone_release

    expect(cloned_release.video).to be_nil
    expect(cloned_release.bottle_shot).to be_nil
  end

end
