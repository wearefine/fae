require 'rails_helper'

describe 'releases#index' do

  it 'should return found' do
    admin_login
    get admin_releases_path

    expect(response.status).to eq(200)
  end

end

describe 'releases#new' do

  it 'should return found' do
    admin_login
    get new_admin_release_path

    expect(response.status).to eq(200)
  end

end

describe 'releases#edit' do

  it 'should return found' do
    release = FactoryGirl.create(:release)
    admin_login
    get edit_admin_release_path(release)

    expect(response.status).to eq(200)
  end

end