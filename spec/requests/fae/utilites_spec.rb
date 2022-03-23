require 'rails_helper'

describe 'utilities#toggle' do

  context 'when role is user' do
    it "shouldn't be able to toggle user's active attr" do
      user_login
      post "/admin/toggle/fae__users/#{Fae::User.first.id}/active", as: :js

      expect(response.status).to eq(401)
    end

    it "shouldn't be able to toggle release's on_prod attr" do
      user_login
      release = FactoryBot.create(:release)
      post "/admin/toggle/releases/#{release.id}/on_prod", as: :json

      expect(response.status).to eq(200)
    end

    it "shouldn't be able to toggle non-boolean attrs" do
      user_login
      release = FactoryBot.create(:release)
      post "/admin/toggle/releases/#{release.id}/wine_id", as: :json

      expect(response.status).to eq(401)
    end

    it "should't expose missing classes" do
      user_login
      post "/admin/toggle/not_a_class/1/on_prod", as: :json

      expect(response.status).to eq(401)
    end
  end

  context 'when role is admin' do
    it "shouldn't be able to elevate privaledges" do
      admin_login
      post "/admin/toggle/fae__users/#{Fae::User.first.id}/role_id", as: :js

      expect(response.status).to eq(401)
    end
  end

  context 'when logged out' do
    it "shouldn't be able to toggle user's active attr" do
      create_super_user

      post "/admin/toggle/fae_users/#{Fae::User.first.id}/active", as: :js
      follow_redirect!

      expect(response.body).to include(I18n.t(:devise)[:failure][:unauthenticated])
    end

    it "shouldn't be able to toggle release's on_prod attr" do
      create_super_user
      release = FactoryBot.create(:release)

      post "/admin/toggle/releases/#{release.id}/on_prod", as: :js
      follow_redirect!

      expect(response.body).to include(I18n.t(:devise)[:failure][:unauthenticated])
    end
  end

end