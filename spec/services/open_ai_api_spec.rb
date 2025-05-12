require 'rails_helper'

RSpec.describe Fae::OpenAiApi, type: :model do
  describe '#describe_image' do
    let(:api) { Fae::OpenAiApi.new }
    let(:url) { File.join('spec', 'support', 'assets', 'test.jpg') }

    context 'when successful' do
      it 'returns a successful response with content' do
        result = api.describe_image(url)
        expect(result[:success]).to be true
        expect(result[:message]).to be_empty
        expect(result[:content]).to eq('A playful beagle puppy is lying down and chewing on a dry leaf.')
      end
      it 'creates an OpenAiApiCall record' do
        expect { api.describe_image(url) }.to change { Fae::OpenAiApiCall.count }.by(1)
        api_call = Fae::OpenAiApiCall.last
        expect(api_call.call_type).to eq('describe_image')
        expect(api_call.tokens).to eq(8529)
      end
    end
    
  end
end