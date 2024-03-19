require 'rails_helper'

describe 'pages#home' do

  before(:each) do
    def fae_path
      Rails.application.routes.url_helpers.fae_path
    end
  end

  context 'when user is logged out' do
    it 'should redirect to the login page' do
      create_super_user
      get fae_path

      expect(response.status).to eq(302)
      expect(response).to redirect_to('/admin/login')
    end
  end

  context 'when user is logged in' do
    it 'should render found' do
      super_admin_login
      get fae_path

      expect(response.status).to eq(200)
    end

    it 'should list all recently updated objects, ordered by most recent first' do
      a_bit_ago = 5.seconds.ago
      wine = FactoryBot.create(:wine, updated_at: a_bit_ago, created_at: a_bit_ago)
      cat = FactoryBot.create(:cat)

      super_admin_login
      get fae_path

      expect(assigns(:list)).to eq([cat, wine])
    end

    it 'should exlude Fae models from dashboard list' do
      fae_role = FactoryBot.create(:fae_role)
      wine = FactoryBot.create(:wine)

      super_admin_login
      get fae_path

      expect(assigns(:list)).to include(wine)
      expect(assigns(:list)).to_not include(fae_role)
    end

    it 'should exlude Fae.dashoard_exclusions from dashboard list' do
      aroma = FactoryBot.create(:aroma)

      super_admin_login
      get fae_path

      expect(assigns(:list)).to_not include(aroma)
    end
  end

end

describe 'pages#help' do

  context 'when user is logged out' do
    it 'should redirect to the login page' do
      create_super_user
      get fae.help_path

      expect(response.status).to eq(302)
      expect(response).to redirect_to('/admin/login')
    end
  end

  context 'when user is logged in' do
    it 'should render help page' do
      super_admin_login
      get fae.help_path

      expect(response.status).to eq(200)
    end
  end

end

describe 'pages#error404' do

  context 'when user is logged out' do
    it 'should redirect to the login page' do
      require 'pry'
      create_super_user
      get '/admin/nothinghere'

      expect(response.status).to eq(302)
      expect(response).to redirect_to('/admin/login')
    end
  end

  context 'when user is logged in' do
    it 'should render 404 page' do
      super_admin_login
      get '/admin/nothinghere'

      expect(response.status).to eq(404)
    end
  end

end
