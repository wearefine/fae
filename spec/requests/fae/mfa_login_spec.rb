require 'rails_helper'

describe 'Two-step MFA login' do
  include ActiveSupport::Testing::TimeHelpers

  let(:password) { 'password1' }

  before do
    create_super_user
    Fae::Option.instance.update!(site_mfa_enabled: true)
  end

  def submit_credentials(user, remember_me: '0')
    post fae.user_session_path, params: { user: { email: user.email, password: password, remember_me: remember_me } }
  end

  def submit_otp(code)
    post fae.user_session_path, params: { user: { otp_attempt: code } }
  end

  def signed_in?
    get fae.root_path
    response.status == 200
  end

  context 'user without MFA' do
    let(:user) { FactoryBot.create(:fae_user, password: password, password_confirmation: password) }

    it 'signs in with just email and password' do
      submit_credentials(user)

      expect(response).to redirect_to(fae.root_path)
      expect(signed_in?).to be true
    end

    it 'does not show the MFA field on the login form' do
      get fae.new_user_session_path

      expect(response.body).to_not include('user_otp_attempt')
    end
  end

  context 'user with MFA' do
    let(:user) { FactoryBot.create(:fae_user, :with_otp, password: password, password_confirmation: password) }

    it 'prompts for the MFA code after a valid password without signing in' do
      submit_credentials(user)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('user_otp_attempt')
      expect(signed_in?).to be false
    end

    it 'does not prompt for the MFA code after an invalid password' do
      post fae.user_session_path, params: { user: { email: user.email, password: 'wrong-password' } }

      expect(response.body).to_not include('user_otp_attempt')
      expect(signed_in?).to be false
    end

    it 'signs in with a valid code' do
      submit_credentials(user)
      submit_otp(user.current_otp)

      expect(response).to redirect_to(fae.root_path)
      expect(signed_in?).to be true
    end

    it 'signs in with a backup code and consumes it' do
      codes = user.generate_otp_backup_codes!
      user.save!

      submit_credentials(user)
      submit_otp(codes.first)

      expect(signed_in?).to be true
      expect(user.reload.invalidate_otp_backup_code!(codes.first)).to be false
    end

    it 'rejects an invalid code and lets the user try again' do
      submit_credentials(user)
      submit_otp('000000')

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include('user_otp_attempt')
      expect(user.reload.failed_attempts).to eq(1)

      submit_otp(user.current_otp)

      expect(signed_in?).to be true
      expect(user.reload.failed_attempts).to eq(0)
    end

    it 'does not accept a code without a valid password first' do
      submit_otp(user.current_otp)

      expect(response).to redirect_to(fae.new_user_session_path)
      expect(signed_in?).to be false
    end

    it 'does not accept a code submitted alongside the password' do
      post fae.user_session_path, params: { user: { email: user.email, password: password, otp_attempt: user.current_otp } }

      expect(signed_in?).to be false
    end

    it 'expires the MFA step after a few minutes' do
      submit_credentials(user)

      travel(Fae::AuthenticateWithOtpTwoFactor::OTP_LOGIN_TIMEOUT + 1.second) do
        submit_otp(user.current_otp)

        expect(response).to redirect_to(fae.new_user_session_path)
        expect(flash[:alert]).to eq(I18n.t('devise.failure.otp_expired'))
        expect(signed_in?).to be false
      end
    end

    it 'locks the account after too many invalid codes' do
      submit_credentials(user)
      Devise.maximum_attempts.times { submit_otp('000000') }

      expect(response).to redirect_to(fae.new_user_session_path)
      expect(user.reload.access_locked?).to be true

      submit_otp(user.current_otp)
      expect(signed_in?).to be false
    end

    it 'carries remember me through to the MFA step' do
      submit_credentials(user, remember_me: '1')
      submit_otp(user.current_otp)

      expect(user.reload.remember_created_at).to be_present
    end
  end
end
