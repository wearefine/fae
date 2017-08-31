module Fae
  class SetupController < ActionController::Base

    helper Fae::FormHelper

    before_action :check_roles

    layout 'devise'

    def first_user
      @option = Fae::Option.instance
      return show_404 if Fae::User.live_super_admins.present?

      @user = Fae::User.new
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
        @option = Fae::Option.instance
        render action: 'first_user', error: t('fae.save_error')
      end
    end

    private

    def show_404
      render template: 'fae/pages/error404.html.slim', layout: 'fae/error.html.slim', status: :not_found
    end

    def show_401
      render template: 'fae/pages/error404.html.slim', layout: 'fae/error.html.slim', status: :unauthorized
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
