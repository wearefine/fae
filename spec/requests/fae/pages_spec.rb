require 'rails_helper'

describe 'pages#home' do

  context 'when user is logged out' do
    it 'should redirect to the login page' do
      get fae_path

      expect(response.status).to eq(302)
      expect(response).to redirect_to(fae.new_user_session_path)
    end
  end

  context 'when user is logged in' do
    it 'should render found' do
      super_admin_login
      get fae_path

      expect(response.status).to eq(200)
    end
  end

end

describe 'pages#help' do

  context 'when user is logged out' do
    it 'should redirect to the login page' do
      get fae.help_path

      expect(response.status).to eq(302)
      expect(response).to redirect_to(fae.new_user_session_path)
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
      get '/admin/nothinghere'

      expect(response.status).to eq(302)
      expect(response).to redirect_to(fae.new_user_session_path)
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
