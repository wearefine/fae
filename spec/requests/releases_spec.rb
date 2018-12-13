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

describe 'releases#create' do

  context 'when from_existing' do

    it 'should clone original item' do
      release = FactoryGirl.create(:release, name: 'short')
      admin_login
      post admin_releases_path(from_existing: release.id)

      expect(Release.all.collect(&:name)).to eq(['short', 'short-2'])
    end

    it 'should modify cloned items name if length validation is triggered' do
      release = FactoryGirl.create(:release, name: 'hey a long name')
      admin_login
      post admin_releases_path(from_existing: release.id)

      expect(Release.all.collect(&:name)).to eq(['hey a long name', 'hey a long na-2'])
    end

  end

end

describe 'releases#show' do

  it 'should return not found' do
    release = FactoryGirl.create(:release)
    admin_login
    get admin_release_path(release)

    expect(response.status).to eq(404)
  end

end
