require 'rails_helper'

describe 'Mux webhooks' do

  let(:secret) { 'mux-test-secret' }
  let(:body) { { type: 'video.asset.ready', data: { id: 'asset123', status: 'ready', playback_ids: [{ id: 'play123', policy: 'public' }] } }.to_json }
  before { allow_any_instance_of(Fae::Video).to receive(:claim_mux_asset) }

  let!(:video) { FactoryGirl.create(:fae_video, asset_id: 'asset123') }

  around do |example|
    original = ENV['MUX_WEBHOOK_SECRET']
    ENV['MUX_WEBHOOK_SECRET'] = secret
    example.run
    ENV['MUX_WEBHOOK_SECRET'] = original
  end

  def signature(timestamp: Time.now.to_i, payload: body, key: secret)
    "t=#{timestamp},v1=#{OpenSSL::HMAC.hexdigest('SHA256', key, "#{timestamp}.#{payload}")}"
  end

  def post_webhook(headers)
    post fae.mux_webhook_path, params: body, headers: headers.merge('CONTENT_TYPE' => 'application/json')
  end

  it 'should process a correctly signed event without a session' do
    post_webhook('Mux-Signature' => signature)

    expect(response.status).to eq(200)
    expect(video.reload.playback_id).to eq('play123')
  end

  it 'should reject a missing signature' do
    post_webhook({})
    expect(response.status).to eq(401)
    expect(video.reload.playback_id).to be_nil
  end

  it 'should reject a signature made with the wrong secret' do
    post_webhook('Mux-Signature' => signature(key: 'wrong'))
    expect(response.status).to eq(401)
  end

  it 'should reject a stale timestamp' do
    post_webhook('Mux-Signature' => signature(timestamp: 10.minutes.ago.to_i))
    expect(response.status).to eq(401)
  end

  it 'should reject everything when no secret is configured' do
    ENV['MUX_WEBHOOK_SECRET'] = nil
    post_webhook('Mux-Signature' => signature)
    expect(response.status).to eq(401)
  end

end
