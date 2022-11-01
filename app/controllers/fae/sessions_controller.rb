module Fae
  class SessionsController < Devise::SessionsController
    # include Fae::AuthenticateWithOtpTwoFactor

    # before_action :configure_permitted_parameters, if: :devise_controller?

    # # prepend_before_action :authenticate_with_otp_two_factor,
    # #                       if: -> { action_name == 'create' && otp_two_factor_enabled? }

    # # protect_from_forgery with: :exception, prepend: true, except: :destroy

    # protected

    # def configure_permitted_parameters
    #   devise_parameter_sanitizer.permit(:sign_in, keys: [:otp_attempt])
    # end

    # def create
    #   self.resource = warden.authenticate!(auth_options)
    #   set_flash_message!(:notice, :signed_in)
    #   sign_in(resource_name, resource)
    #   yield resource if block_given?
    #   respond_with resource, location: after_sign_in_path_for(resource)
    # end

  end
end

# class SessionsController < Devise::SessionsController

#   protected

#   def configure_permitted_parameters
#     devise_parameter_sanitizer.permit(:sign_in, keys: [:otp_attempt])
#   end

# end