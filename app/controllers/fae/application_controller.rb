class Fae::ApplicationController < ActionController::Base
  include Fae::NavItems
  include Fae::ApplicationControllerConcern

  helper Fae::ViewHelper

  before_filter :authenticate_user!
  before_filter :build_nav
  before_filter :set_option
  before_filter :detect_cancellation


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
    flash.now[:alert] = 'Your changes were not saved.' if params[:cancelled].present? && params[:cancelled]== "true"
  end

  def build_nav
    if current_user
      @fae_nav_items = [
        { text: "Dashboard", path: fae.root_path, class_name: "main_nav-link-dashboard" }
        ]

      @fae_nav_items += nav_items if nav_items.present?

      if current_user.super_admin?
        sublinks = []
        sublinks << { text: 'Users', path: fae.users_path }
        sublinks << { text: 'Root Settings', path: fae.option_path }
        @fae_nav_items << { text: 'Admin', path: '#', class_name: 'main_nav-link-users', sublinks: sublinks }
      elsif current_user.admin?
        @fae_nav_items << { text: 'Users', path: fae.users_path, class_name: 'main_nav-link-users' }
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

end