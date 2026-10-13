require 'rails_helper'

# Failed saves respond with 422 and successful saves redirect with 303, so clients
# (jquery_ujs today, Turbo later) can tell the two apart and follow redirects with a GET.
describe 'response statuses' do
  let(:routes) { Rails.application.routes.url_helpers }

  before { admin_login }

  describe 'top-level forms' do
    it 'redirects with 303 after a successful create' do
      wine = FactoryBot.create(:wine)
      post routes.admin_releases_path, params: { release: { name: 'Fresh', release_date: '2020-01-01', wine_id: wine.id } }

      expect(response.status).to eq(303)
      expect(response).to redirect_to('/admin/releases')
    end

    it 'responds with 422 and the form after a failed create' do
      post routes.admin_releases_path, params: { release: { name: '' } }

      expect(response.status).to eq(422)
      expect(response.body).to include('field_with_errors')
    end

    it 'redirects with 303 after a successful update' do
      release = FactoryBot.create(:release)
      patch routes.admin_release_path(release), params: { release: { name: 'Renamed' } }

      expect(response.status).to eq(303)
    end

    it 'responds with 422 after a failed update' do
      release = FactoryBot.create(:release)
      patch routes.admin_release_path(release), params: { release: { name: '' } }

      expect(response.status).to eq(422)
    end

    it 'redirects with 303 after a delete' do
      release = FactoryBot.create(:release)
      delete routes.admin_release_path(release)

      expect(response.status).to eq(303)
      expect(Release.exists?(release.id)).to be(false)
    end

    it 'keeps 302 for redirects after a GET' do
      get routes.new_admin_release_path

      expect(response.status).to eq(302)
    end

    it 'respects an explicit redirect status' do
      post routes.admin_releases_path(from_existing: FactoryBot.create(:release).id)

      expect(response.status).to eq(303)
    end
  end

  describe 'nested forms' do
    let(:wine) { FactoryBot.create(:wine) }

    it 'responds with 422 and the form HTML after a failed create' do
      post routes.admin_winemakers_path, params: { winemaker: { name: '', wine_id: wine.id, region_type: 1 } }

      expect(response.status).to eq(422)
      expect(response.body).to include('nested-form')
    end

    it 'responds with 200 and the table after a successful create' do
      post routes.admin_winemakers_path, params: { winemaker: { name: 'Joe', wine_id: wine.id, region_type: 1 } }

      expect(response.status).to eq(200)
      expect(response.body).to include('Joe')
    end

    # The dummy's update action predates 422, like host controllers that haven't been updated
    it 'still accepts controllers that render a failed form with 200' do
      winemaker = FactoryBot.create(:winemaker, wine: wine, region_type: 1)
      patch routes.admin_winemaker_path(winemaker), params: { winemaker: { name: '' } }

      expect(response.status).to eq(200)
      expect(response.body).to include('nested-form')
    end
  end

  describe 'users' do
    it 'responds with 422 after a failed create' do
      post Fae::Engine.routes.url_helpers.users_path, params: { user: { email: '' } }

      expect(response.status).to eq(422)
    end
  end
end
