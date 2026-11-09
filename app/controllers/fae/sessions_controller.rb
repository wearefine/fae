module Fae
  class SessionsController < Devise::SessionsController
    include Fae::AuthenticateWithOtpTwoFactor

    # Devise allows params (email/password) authentication for the entire
    # create request. Fae's before_actions call current_user, which would then
    # run the password strategy before we get a chance to ask for the MFA
    # code. Only allow it once we hand off to Devise below.
    skip_before_action :allow_params_authentication!, only: :create

    def new
      clear_pending_otp_login
      super
    end

    def create
      if otp_attempt_submitted?
        authenticate_with_otp_two_factor
      else
        clear_pending_otp_login

        if (user = user_pending_otp_from_credentials)
          prompt_for_otp_two_factor(user)
        else
          allow_params_authentication!
          super
        end
      end
    end

  end
end
