require 'rails_helper'

# Devise's failures and redirects follow the same conventions as the rest of the admin
# (see response_statuses_spec): 422 for a rejected submission and 303 for a redirect after one.
describe 'Devise response statuses' do
  let(:routes) { Rails.application.routes.url_helpers }
  let!(:user) { create_super_user }

  describe 'logging in' do
    it 'redirects with 303 after a successful login' do
      post fae.user_session_path, params: { user: { email: user.email, password: 'password' } }

      expect(response.status).to eq(303)
    end

    it 'responds with 422 and the form for a wrong password' do
      post fae.user_session_path, params: { user: { email: user.email, password: 'nope' } }

      expect(response.status).to eq(422)
      expect(response.body).to include('user_email')
    end

    it 'responds with 422 for an unknown user' do
      post fae.user_session_path, params: { user: { email: 'nobody@example.com', password: 'nope' } }

      expect(response.status).to eq(422)
    end

    it 'responds with 422 for a blank email' do
      post fae.user_session_path, params: { user: { email: '', password: 'password' } }

      expect(response.status).to eq(422)
    end
  end

  describe 'with two factor authentication' do
    let!(:otp_user) do
      FactoryBot.create(:fae_user, :with_otp, email: 'otp@test.com', password: 'passord1', password_confirmation: 'passord1', active: true)
    end

    before do
      option = Fae::Option.instance
      option.site_mfa_enabled = true
      option.save
    end

    it 'prompts for the code with 422, since the page answers a form submission' do
      post fae.user_session_path, params: { user: { email: otp_user.email, password: 'passord1' } }

      expect(response.status).to eq(422)
      expect(response.body).to include('user_otp_attempt')
    end

    it 'responds with 422 for an invalid code' do
      post fae.user_session_path, params: { user: { email: otp_user.email, password: 'passord1' } }
      post fae.user_session_path, params: { user: { email: otp_user.email, password: 'passord1', otp_attempt: 'invalid' } }

      expect(response.status).to eq(422)
    end
  end

  describe 'resetting a password' do
    it 'responds with 422 for an unknown email' do
      post '/admin/users/password', params: { user: { email: 'nobody@example.com' } }

      expect(response.status).to eq(422)
    end

    it 'redirects with 303 for a known email' do
      post '/admin/users/password', params: { user: { email: user.email } }

      expect(response.status).to eq(303)
    end
  end
end
