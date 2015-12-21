module Fae
  class ApplicationController < ActionController::Base
    include Fae::NavItems
    include Fae::ApplicationControllerConcern

    helper Fae::ViewHelper

    before_filter :first_user_redirect
    before_filter :authenticate_user!
    before_filter :build_nav
    before_filter :set_option
    before_filter :detect_cancellation
    before_filter :set_change_user

    private

    def super_admin_only
      redirect_to fae.root_path, flash: { error: t('fae.unauthorized_error') } unless current_user.super_admin?
    end

    def admin_only
      redirect_to fae.root_path, flash: { error: t('fae.unauthorized_error') } unless current_user.super_admin? || current_user.admin?
    end

    def show_404
      render template: 'fae/pages/error404.html.slim', layout: 'fae/error.html.slim', status: :not_found
    end

    def set_option
      @option = Fae::Option.instance
    end

    def detect_cancellation
      flash.now[:error] = 'Your changes were not saved.' if params[:cancelled].present? && params[:cancelled]== "true"
    end

    def build_nav
      if current_user
        @fae_nav_items = [
          { text: "Dashboard", path: fae.root_path, class_name: '-dashboard' }
          ]

        @fae_nav_items += nav_items if nav_items.present?

        if current_user.super_admin?
          sublinks = []
          sublinks << { text: 'Users', path: fae.users_path, class_name: '-users' }
          sublinks << { text: 'Root Settings', path: fae.option_path, class_name: '-settings'}
          sublinks << { text: 'Activity Log', path: fae.activity_log_path, class_name: '-activity'}
          @fae_nav_items << { text: 'Admin', path: '#', class_name: 'main_nav-link-admin', sublinks: sublinks }
        elsif current_user.admin?
          @fae_nav_items << { text: 'Users', path: fae.users_path, class_name: '-users' }
          @fae_nav_items << { text: 'Activity Log', path: fae.activity_log_path, class_name: '-activity'}
        end
      end
    end

    # redirect to login after sign out
    def after_sign_out_path_for(resource_or_scope)
      fae.new_user_session_path
    end

    # redirect to requested page after sign in
    def after_sign_in_path_for(resource)
      request.env['omniauth.origin'] || stored_location_for(resource) || fae.root_path
    end

    def first_user_redirect
      redirect_to fae.first_user_path if Fae::User.live_super_admins.blank?
    end

    def set_change_user
      Fae::Change.current_user = current_user.id if current_user.present?
    end

  end
end
