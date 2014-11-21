require 'rails_helper'

describe 'options#edit' do

  context 'when role is super admin' do
    it 'should be able to access settings' do
      super_admin_login
      get fae.option_path

      expect(response.status).to eq(200)
    end
  end

  context 'when role is admin' do
    it "shouldn't be able to access settings" do
      admin_login
      get fae.option_path

      expect(response.status).to eq(302)
      expect(response).to redirect_to(fae.root_path)
    end
  end

  context 'when role is user' do
    it "shouldn't be able to access settings" do
      user_login
      get fae.option_path

      expect(response.status).to eq(302)
      expect(response).to redirect_to(fae.root_path)
    end
  end

  context 'when logged out' do
    it "shouldn't be able to access users" do
      get fae.option_path

      expect(response.status).to eq(302)
      expect(response).to redirect_to(fae.new_user_session_path)
    end
  end

end