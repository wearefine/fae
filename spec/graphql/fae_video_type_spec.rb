require 'rails_helper'

describe Types::FaeVideoType do

  # Fae's GraphQL types live in the host app, so test this one with a minimal schema
  let(:schema) do
    query = Class.new(Types::BaseObject) do
      graphql_name 'VideoTestQuery'
      field :video, Types::FaeVideoType, null: true do
        argument :id, GraphQL::Types::ID, required: true
      end
      define_method(:video) { |id:| Fae::Video.find(id) }
    end
    Class.new(GraphQL::Schema) { query(query) }
  end

  let(:fields) { 'id playbackId status ready title alt duration aspectRatio thumbnailUrl createdAt updatedAt' }

  before { allow_any_instance_of(Fae::Video).to receive(:claim_mux_asset) }

  it 'should expose a ready video' do
    video = FactoryBot.create(:fae_video, asset_id: 'asset123', playback_id: 'play123', status: 'ready',
      title: 'clip.mp4', alt: 'A clip', duration: 42.5, aspect_ratio: '16:9')

    result = schema.execute("{ video(id: #{video.id}) { #{fields} } }").to_h
    data = result.dig('data', 'video')

    expect(result['errors']).to be_nil
    expect(data).to include(
      'id' => video.id.to_s,
      'playbackId' => 'play123',
      'status' => 'ready',
      'ready' => true,
      'title' => 'clip.mp4',
      'alt' => 'A clip',
      'duration' => 42.5,
      'aspectRatio' => '16:9',
      'thumbnailUrl' => 'https://image.mux.com/play123/thumbnail.jpg?width=640'
    )
  end

  it 'should return nulls and ready: false while processing' do
    video = FactoryBot.create(:fae_video, asset_id: 'asset123', status: 'preparing')

    data = schema.execute("{ video(id: #{video.id}) { #{fields} } }").to_h.dig('data', 'video')

    expect(data['ready']).to eq(false)
    expect(data['playbackId']).to be_nil
    expect(data['thumbnailUrl']).to be_nil
  end

end
