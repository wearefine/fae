require 'rails_helper'

describe 'releases#index' do

  before do
    def admin_releases_path
      Rails.application.routes.url_helpers.admin_releases_path
    end
  end

  it 'should return found' do
    admin_login
    get admin_releases_path

    expect(response.status).to eq(200)
  end

end

describe 'releases#new' do

  before do
    def new_admin_release_path
      Rails.application.routes.url_helpers.new_admin_release_path
    end
  end

  it 'should return found' do
    admin_login
    get new_admin_release_path

    expect(response.status).to eq(200)
  end

end

describe 'releases#edit' do

  before do
    def edit_admin_release_path(release)
      Rails.application.routes.url_helpers.edit_admin_release_path(release)
    end
  end

  it 'should return found' do
    release = FactoryBot.create(:release)
    admin_login
    get edit_admin_release_path(release)

    expect(response.status).to eq(200)
  end

end

describe 'releases#create' do

  before do
    def admin_releases_path(release)
      Rails.application.routes.url_helpers.admin_releases_path(release)
    end
  end

  context 'when from_existing' do

    it 'should clone original item' do
      release = FactoryBot.create(:release, name: 'short')
      admin_login
      post admin_releases_path(from_existing: release.id)

      expect(Release.all.collect(&:name)).to eq(['short', 'short-2'])
    end

    it 'should modify cloned items name if length validation is triggered' do
      release = FactoryBot.create(:release, name: 'hey a long name')
      admin_login
      post admin_releases_path(from_existing: release.id)

      expect(Release.all.collect(&:name)).to eq(['hey a long name', 'hey a long na-2'])
    end

  end

end

describe 'releases#show' do

  before do
    def admin_release_path(release)
      Rails.application.routes.url_helpers.admin_release_path(release)
    end
  end

  it 'should return not found' do
    release = FactoryBot.create(:release)
    admin_login
    get admin_release_path(release)

    expect(response.status).to eq(404)
  end

end
