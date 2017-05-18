require 'rails_helper'

describe 'images#create_html_embedded' do

  before do
    allow_any_instance_of(CarrierWave::Uploader::Base)
      .to receive(:store!)
  end

  it 'should return a json' do
    user_login
    post fae.html_embedded_image_path,
         params: { asset: Rails.root.join('/spec/support/images/test.jpeg') }

    expect(response.body).to eq '{"success":true,"file":null}'
  end
end
