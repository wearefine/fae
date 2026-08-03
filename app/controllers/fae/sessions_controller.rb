module Fae
  class SessionsController < Devise::SessionsController
    include Fae::InertiaAuthenticatable

    def new
      self.resource = resource_class.new

      render_fae_auth 'Fae/Auth/SignIn',
        title: 'Sign In',
        submit_path: fae.user_session_path,
        submit_text: 'Submit',
        fields: sign_in_fields
    end

    protected

    def sign_in_params
      devise_parameter_sanitizer.permit(:sign_in, keys: [:otp_attempt])
    end

    private

    def sign_in_fields
      fields = [
        # required: false throughout, matching the legacy form -- Devise
        # reports a bad email or password as one flash message rather than
        # per field, so marking either up would be misleading.
        #
        # A failed sign in is recalled into this action, so the address is put
        # back rather than making the visitor retype it. The password is not.
        { name: :email, type: :email, autocomplete: 'username', value: params.dig(:user, :email) },
        { name: :password, type: :password, autocomplete: 'current-password' }
      ]

      if @option.site_mfa_enabled
        fields << {
          name: :otp_attempt,
          type: :text,
          label: 'MFA Code',
          autocomplete: 'one-time-code',
          helper_text: 'Contact an admin if you don’t have access to your multi-factor authentication code.'
        }
      end

      fields << { name: :remember_me, type: :checkbox } if devise_mapping.rememberable?
      fields
    end

    # A bad sign in never reaches respond_with: Warden throws, and
    # Devise::FailureApp recalls this controller's #new with the message
    # already in flash.now.
    def fae_auth_failure_path
      fae.new_user_session_path
    end
  end
end
