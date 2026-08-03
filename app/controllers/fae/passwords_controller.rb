module Fae
  class PasswordsController < Devise::PasswordsController
    include Fae::InertiaAuthenticatable

    def new
      self.resource = resource_class.new

      render_fae_auth 'Fae/Auth/NewPassword',
        title: 'Reset Password',
        intro: 'What email do you use to sign in? We’ll send you a link to set a new password.',
        submit_path: password_path(resource_name),
        submit_text: 'Submit',
        fields: [
          { name: :email, type: :email, required: true, autocomplete: 'username' }
        ]
    end

    def edit
      self.resource = resource_class.new
      set_minimum_password_length

      render_fae_auth 'Fae/Auth/EditPassword',
        title: 'Change Your Password',
        submit_path: password_path(resource_name),
        submit_method: 'put',
        submit_text: 'Change my password',
        # The token identifies the account; it arrives in the emailed link and
        # has to travel back with the new password.
        hidden: { reset_password_token: params[:reset_password_token] },
        fields: [
          { name: :password, type: :password, label: 'New password', required: true,
            autocomplete: 'new-password' },
          { name: :password_confirmation, type: :password, label: 'Confirm your new password',
            required: true, autocomplete: 'new-password' }
        ]
    end

    private

    def fae_auth_failure_path
      return new_password_path(resource_name) unless action_name == 'update'

      edit_password_path(resource_name, reset_password_token: params.dig(:user, :reset_password_token))
    end
  end
end
