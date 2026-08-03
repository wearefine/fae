module Fae
  class SetupController < ActionController::Base

    include Fae::InertiaAuthenticatable

    # Not a Fae::ApplicationController subclass, so the engine's helpers are
    # not picked up automatically -- the Inertia layout needs page_title and
    # body_class from ApplicationHelper.
    helper Fae::ApplicationHelper
    helper Fae::FormHelper

    before_action :check_roles

    def first_user
      @option = Fae::Option.instance
      return show_404 if Fae::User.live_super_admins.present?

      @user = Fae::User.new
      render_first_user
    end

    def create_first_user
      return show_401 if Fae::User.live_super_admins.present?

      @user         = Fae::User.new(user_params)
      super_admin   = Fae::Role.find_by_name('super admin')
      @user.role    = super_admin
      @user.active  = true

      if @user.save
        sign_in(@user)
        redirect_to fae.root_path
      else
        redirect_to fae.first_user_path,
                    inertia: { errors: fae_inertia_errors(@user) },
                    flash: { alert: t('fae.save_error') }
      end
    end

    private

    def render_first_user
      render_fae_auth 'Fae/Auth/FirstUser',
        title: 'Welcome to Fae',
        intro: t('fae.setup.prompt'),
        submit_path: fae.first_user_path,
        submit_text: t('fae.form.save'),
        fields: [
          { name: :first_name, required: true, autocomplete: 'given-name' },
          { name: :last_name, autocomplete: 'family-name' },
          { name: :email, type: :email, required: true, autocomplete: 'username' },
          { name: :password, type: :password, required: true, autocomplete: 'new-password',
            helper_text: t('fae.setup.password') },
          { name: :password_confirmation, type: :password, required: true, autocomplete: 'new-password' }
        ]
    end

    def show_404
      render 'fae/pages/error404', layout: 'fae/error', status: :not_found
    end

    def show_401
      render 'fae/pages/error404', layout: 'fae/error', status: :unauthorized
    end

    def user_params
      params.require(:user).permit(:email, :first_name, :last_name, :password, :password_confirmation)
    end

    def check_roles
      if Fae::Role.all.empty?
        raise "Role 'super admin' does not exist in Fae::Role, run rake fae:seed_db"
      end
    end
  end
end
