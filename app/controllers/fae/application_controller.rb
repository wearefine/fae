module Fae
  class ApplicationController < ActionController::Base

    before_filter :authenticate_user!
    before_filter :build_nav

  private

    def super_admin_only
      redirect_to root_path, notice: 'You are not authorized to view that page.' unless current_user.super_admin?
    end

    def show_404
      render template: 'pages/error404.html.erb', status: :not_found
    end

    def build_nav
      @fae_nav_items = [
        { text: "Dashboard", path: root_path, class_name: "main_nav-link-dashboard" }
        ]

      @fae_nav_items += Fae.nav_items

      if current_user.try(:super_admin?)
        @fae_nav_items << { text: "Users", path: '#', class_name: "main_nav-link-users", sublinks: [
            { text: "Users", path: users_path },
            { text: "Roles", path: roles_path }
          ]
        }
      end
    end

  end
end
