require 'rails_helper'

describe 'users#index' do

  let(:edit_user) { FactoryGirl.create(:fae_user) }

  context 'when role is super admin' do
    it 'should be able to access users' do
      super_admin_login
      get fae.users_path

      expect(response.status).to eq(200)
    end

    it 'should be able to access user edit page' do
      super_admin_login
      get fae.edit_user_path(edit_user)

      expect(response.status).to eq(200)
    end
  end

  context 'when role is admin' do
    it 'should be able to access users' do
      admin_login
      get fae.users_path

      expect(response.status).to eq(200)
    end

    it 'should be able to access user edit page' do
      admin_login
      get fae.edit_user_path(edit_user)

      expect(response.status).to eq(200)
    end
  end

  context 'when role is user' do
    it "shouldn't be able to access users" do
      user_login
      get fae.users_path

      expect(response.status).to eq(302)
      expect(response).to redirect_to(fae.root_path)
    end

    it "shouldn't be able to access users" do
      user_login
      get fae.edit_user_path(edit_user)

      expect(response.status).to eq(302)
      expect(response).to redirect_to(fae.root_path)
    end
  end

  context 'when logged out' do
    it "shouldn't be able to access users" do
      get fae.users_path

      expect(response.status).to eq(302)
      expect(response).to redirect_to(fae.new_user_session_path)
    end
  end

end
