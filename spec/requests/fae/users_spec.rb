require 'rails_helper'

describe 'users#index' do

  before(:each) do
    def admin_teams_path
      Rails.application.routes.url_helpers.admin_teams_path
    end
  end

  context 'when role is super admin' do
    before do
      super_admin_login
    end

    it 'should be able to access users' do
      get fae.users_path

      expect(response.status).to eq(200)
    end

    it 'should be able to access resources restricted to super admin role type' do
      get admin_teams_path

      expect(response.status).to eq(200)
    end
  end

  context 'when role is admin' do
    before do
      admin_login
    end

    it 'should be able to access users' do
      get fae.users_path

      expect(response.status).to eq(200)
    end

    it 'should be able to access resources restricted to admin role type' do
      get admin_teams_path

      expect(response.status).to eq(200)
    end
  end

  context 'when role is user' do
    before do
      user_login
    end

    it "shouldn't be able to access users" do
      get fae.users_path

      expect(response.status).to eq(302)
      expect(response).to redirect_to(fae.root_path)
    end

    it 'should not be able to access resources restricted for user role type' do
      get admin_selling_points_path

      expect(response.status).to eq(404)
    end
  end

  context 'when logged out' do
    it "shouldn't be able to access users" do
      create_super_user
      get fae.users_path

      expect(response.status).to eq(302)
      expect(response).to redirect_to('/admin/login')
    end
  end

end

describe 'users#edit' do

  let(:edit_user) { FactoryBot.create(:fae_user) }

  context 'when role is super admin' do
    before do
      super_admin_login
    end

    it 'should be able to access user edit page' do
      get fae.edit_user_path(edit_user)

      expect(response.status).to eq(200)
    end

    it "should cancel to users#index" do
      get fae.edit_user_path(edit_user)

      expect(response.body).to include('href="/admin/users" id="js-header-cancel"')
    end
  end

  context 'when role is admin' do
    before do
      admin_login
    end

    it 'should be able to access user edit page' do
      get fae.edit_user_path(edit_user)

      expect(response.status).to eq(200)
    end
  end

  context 'when role is user' do
    before do
      user_login
    end

    it "shouldn't be able to access users" do
      get fae.edit_user_path(edit_user)

      expect(response.status).to eq(302)
      expect(response).to redirect_to(fae.root_path)
    end
  end

end

describe 'users#settings' do

  context 'when role is super admin' do
    before do
      super_admin_login
    end

    it "should cancel to dashboard" do
      get fae.settings_path

      expect(response.body).to include('href="/admin/" id="js-header-cancel"')
    end
  end

  context 'when role is user' do
    before do
      user_login
    end

    it "should cancel to dashboard" do
      get fae.settings_path

      expect(response.body).to include('href="/admin/" id="js-header-cancel"')
    end
  end

  context 'when logged out' do
    it "shouldn't be able to access settings" do
      create_super_user
      get fae.settings_path

      expect(response.status).to eq(302)
      expect(response).to redirect_to('/admin/login')
    end
  end

end
