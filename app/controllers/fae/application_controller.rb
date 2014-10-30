class Fae::ApplicationController < ActionController::Base

  helper Fae::ViewHelper

  before_filter :authenticate_user!
  before_filter :build_nav
  before_filter :set_option


private

  def restricted
    redirect_to fae.root_path, flash: {error: 'You are not authorized to view that page.'}
  end

  def super_admin_only
    redirect_to fae.root_path, flash: {error: 'You are not authorized to view that page.'} unless current_user.super_admin?
  end

  def admin_only
    redirect_to fae.root_path, flash: {error: 'You are not authorized to view that page.'} unless current_user.super_admin? || current_user.admin?
  end

  def show_404
    render template: 'fae/pages/error404.html.erb', layout: 'fae/error.html.erb', status: :not_found
  end

  def set_option
    @option = Fae::Option.first
  end

  def build_nav
    if current_user
      @fae_nav_items = [
        { text: "Dashboard", path: fae.root_path, class_name: "main_nav-link-dashboard" }
        ]

      @fae_nav_items += Fae.nav_items

      if current_user.admin? || current_user.super_admin?
        sublinks = []
        sublinks << { text: "Users", path: fae.users_path } if current_user.admin? || current_user.super_admin?
        sublinks << { text: "Root Settings", path: fae.option_path } if current_user.super_admin?
        @fae_nav_items << { text: "Admin", path: '#', class_name: "main_nav-link-users", sublinks: sublinks}
      end
    end
  end

  # redirect to Fae root path on sign out
  def after_sign_out_path_for(resource_or_scope)
    fae.new_user_session_path
  end

end