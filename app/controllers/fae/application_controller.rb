module Fae
  class ApplicationController < ActionController::Base

    before_filter :authenticate_user!

  private

    def super_admin_only
      redirect_to root_path, notice: 'You are not authorized to view that page.' unless current_user.super_admin?
    end

    def show_404
      render template: 'pages/error404.html.erb', status: :not_found
    end

  end
end
