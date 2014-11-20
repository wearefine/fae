require 'rails_helper'

describe 'User access' do

  context 'is super admin' do
    it 'should be able to access settings' do
      super_admin_login
      get fae.option_path

      expect(response.status).to eq(200)
    end

    it 'should be able to access users' do
      super_admin_login
      get fae.users_path

      expect(response.status).to eq(200)
    end
  end

  context 'is admin' do
    it "shouldn't be able to access settings" do
      admin_login
      get fae.option_path

      expect(response.status).to eq(302)
      expect(response).to redirect_to(fae.root_path)
    end

    it 'should be able to access users' do
      admin_login
      get fae.users_path

      expect(response.status).to eq(200)
    end
  end

  context 'is user' do
    it "shouldn't be able to access settings" do
      user_login
      get fae.option_path

      expect(response.status).to eq(302)
      expect(response).to redirect_to(fae.root_path)
    end

    it "shouldn't be able to access users" do
      user_login
      get fae.users_path

      expect(response.status).to eq(302)
      expect(response).to redirect_to(fae.root_path)
    end
  end

end