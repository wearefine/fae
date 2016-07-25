require 'rails_helper'

describe 'utilities#toggle' do

  context 'when role is user' do
    it "shouldn't be able to toggle user's active attr" do
      user_login
      post '/admin/toggle/fae__users/1/active', as: :js

      expect(response.status).to eq(401)
    end

    it "shouldn be able to toggle release's on_prod attr" do
      user_login
      release = FactoryGirl.create(:release)
      post "/admin/toggle/releases/#{release.id}/on_prod", as: :json

      expect(response.status).to eq(200)
    end
  end

  context 'when logged out' do
    it "shouldn't be able to toggle user's active attr" do
      create_super_user
      post '/admin/toggle/fae_users/1/active', as: :js

      expect(response.status).to eq(401)
    end

    it "shouldn't be able to toggle release's on_prod attr" do
      create_super_user
      release = FactoryGirl.create(:release)
      post "/admin/toggle/releases/#{release.id}/on_prod", as: :js

      expect(response.status).to eq(401)
    end
  end

end