require 'rails_helper'

describe 'Draft support' do
  # Define path helpers
  def new_admin_beer_path
    Rails.application.routes.url_helpers.new_admin_beer_path
  end

  def edit_admin_beer_path(beer, options = {})
    Rails.application.routes.url_helpers.edit_admin_beer_path(beer, options)
  end

  def admin_beer_path(beer)
    Rails.application.routes.url_helpers.admin_beer_path(beer)
  end

  def admin_beers_path
    Rails.application.routes.url_helpers.admin_beers_path
  end

  def new_admin_release_path
    Rails.application.routes.url_helpers.new_admin_release_path
  end

  def admin_release_path(release)
    Rails.application.routes.url_helpers.admin_release_path(release)
  end

  before(:each) do
    admin_login
  end

  describe 'with model that has draft support (Beer)' do
    describe 'new action' do
      it 'creates a draft record and redirects to edit' do
        initial_count = Beer.count
        get new_admin_beer_path

        expect(response.status).to eq(302)
        expect(Beer.count).to eq(initial_count + 1)
        
        beer = Beer.last
        expect(beer.draft).to be true
        expect(response).to redirect_to(edit_admin_beer_path(beer, draft: true))
      end
    end

    describe 'update action' do
      it 'sets draft to false on successful update' do
        beer = FactoryBot.create(:beer, name: 'Draft Beer', draft: true)

        patch admin_beer_path(beer), params: { beer: { name: 'Published Beer' } }

        beer.reload
        expect(beer.draft).to be false
      end

      it 'keeps draft as true on failed validation' do
        beer = FactoryBot.create(:beer, name: 'Draft Beer', draft: true)

        patch admin_beer_path(beer), params: { beer: { name: '' } }  # name is required

        beer.reload
        expect(beer.draft).to be true
      end
    end

    describe 'index action' do
      it 'excludes draft records from the list' do
        draft_beer = FactoryBot.create(:beer, name: 'Draft Beer', draft: true)
        published_beer = FactoryBot.create(:beer, name: 'Published Beer', draft: false)

        get admin_beers_path

        expect(response.body).to include('Published Beer')
        expect(response.body).not_to include('Draft Beer')
      end
    end
  end

  describe 'with model that does not have draft support (Release)' do
    describe 'new action' do
      it 'creates a record and redirects to edit' do
        initial_count = Release.count
        get new_admin_release_path

        expect(response.status).to eq(302)
        expect(Release.count).to eq(initial_count + 1)

        release = Release.last
        expect(release.respond_to?(:draft)).to be false
      end
    end

    describe 'update action' do
      it 'updates record normally without draft field' do
        release = FactoryBot.create(:release, name: 'Old Name', release_date: Date.today)

        patch admin_release_path(release), params: { release: { name: 'New Name' } }

        release.reload
        expect(release.name).to eq('New Name')
      end
    end
  end
end
