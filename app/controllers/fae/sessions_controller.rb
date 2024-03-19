module Fae
  class SessionsController < Devise::SessionsController

    protected

    def sign_in_params
      devise_parameter_sanitizer.permit(:sign_in, keys: [:otp_attempt])
    end

  end
end
