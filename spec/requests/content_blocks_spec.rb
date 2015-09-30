require 'rails_helper'

describe 'content_blocks#index' do

  it 'should return found' do
    admin_login
    get fae.pages_path

    expect(response.status).to eq(200)
  end

end

describe 'content_blocks#edit' do

  it 'should return found' do
    admin_login
    get fae.edit_content_block_path('home')

    expect(response.status).to eq(200)
  end

end
