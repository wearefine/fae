module Fae
  class UnlocksController < Devise::UnlocksController
    include Fae::InertiaAuthenticatable

    def new
      self.resource = resource_class.new

      render_fae_auth 'Fae/Auth/NewUnlock',
        title: 'Resend Unlock Instructions',
        submit_path: unlock_path(resource_name),
        submit_text: 'Resend unlock instructions',
        fields: [
          { name: :email, type: :email, required: true, autocomplete: 'username' }
        ]
    end

    private

    def fae_auth_failure_path
      new_unlock_path(resource_name)
    end
  end
end
