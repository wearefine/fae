module Fae
  # Two-step login for users with MFA enabled.
  #
  # The login form only asks for email and password. When those are correct
  # for a user who has an authenticator set up, we remember who they are in
  # the session and render a second form asking for their MFA code (or one of
  # their backup codes). Users without MFA sign in through the normal
  # Devise/Warden flow in a single step.
  module AuthenticateWithOtpTwoFactor
    extend ActiveSupport::Concern

    OTP_LOGIN_SESSION_KEY = :fae_otp_login
    OTP_LOGIN_TIMEOUT = 5.minutes

    private

    # True when the request is a submission of the MFA code form.
    def otp_attempt_submitted?
      params[resource_name].respond_to?(:key?) && params[resource_name].key?(:otp_attempt)
    end

    # Returns the user if the submitted email/password are valid and that user
    # must provide an MFA code to finish signing in. Returns nil otherwise so
    # the request falls through to the standard Devise flow, which takes care
    # of failure messages and failed attempt tracking.
    def user_pending_otp_from_credentials
      email = params.dig(resource_name, :email)
      password = params.dig(resource_name, :password)
      return if email.blank? || password.blank?

      user = resource_class.find_for_database_authentication(email: email)
      return unless user&.otp_required_for_login?
      return unless user.active_for_authentication?

      user if user.valid_password?(password)
    end

    def prompt_for_otp_two_factor(user)
      session[OTP_LOGIN_SESSION_KEY] = {
        'user_id' => user.id,
        'started_at' => Time.current.to_i,
        'remember_me' => params.dig(resource_name, :remember_me) == '1'
      }
      render_otp_form
    end

    def authenticate_with_otp_two_factor
      user = user_pending_otp_from_session
      return restart_login(:otp_expired) unless user
      return restart_login(user.inactive_message) unless user.active_for_authentication?

      if otp_attempt.blank?
        flash.now[:alert] = I18n.t('devise.failure.otp_blank')
        return render_otp_form(status: :unprocessable_entity)
      end

      # valid_for_authentication? is Devise's lockable hook: failed codes count
      # toward the same lockout as failed passwords.
      if user.valid_for_authentication? { valid_otp_attempt?(user) }
        user.remember_me = otp_login_state['remember_me']
        clear_pending_otp_login

        self.resource = user
        set_flash_message!(:notice, :signed_in)
        sign_in(resource_name, user)
        respond_with user, location: after_sign_in_path_for(user)
      elsif user.access_locked?
        restart_login(:locked)
      else
        flash.now[:alert] = I18n.t('devise.failure.invalid_otp')
        render_otp_form(status: :unprocessable_entity)
      end
    end

    def valid_otp_attempt?(user)
      return true if user.validate_and_consume_otp!(otp_attempt)

      user.invalidate_otp_backup_code!(otp_attempt) && user.save(validate: false)
    end

    def otp_attempt
      params.dig(resource_name, :otp_attempt).to_s.gsub(/\s+/, '')
    end

    def otp_login_state
      session[OTP_LOGIN_SESSION_KEY] || {}
    end

    def user_pending_otp_from_session
      state = otp_login_state
      return if state['user_id'].blank?
      return if Time.at(state['started_at'].to_i) < OTP_LOGIN_TIMEOUT.ago

      user = resource_class.find_by(id: state['user_id'])
      user if user&.otp_required_for_login?
    end

    def clear_pending_otp_login
      session.delete(OTP_LOGIN_SESSION_KEY)
    end

    def restart_login(message)
      clear_pending_otp_login
      flash[:alert] = message.is_a?(Symbol) ? I18n.t("devise.failure.#{message}") : message
      redirect_to new_session_path(resource_name)
    end

    def render_otp_form(status: :ok)
      self.resource = resource_class.new
      render 'devise/sessions/two_factor', status: status
    end

  end
end
