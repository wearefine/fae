module Fae
  class ApplicationController < ActionController::Base

    before_filter :set_defaults, :authenticate_user!

    def set_defaults
      @page_title = "Kimpton Hotels CMS"
      @highlight_colors = [ 'kimpton_blue', 'orange', 'purple', 'merlot', 'rust', 'suede', 'indigo', 'cyan', 'aqua_blue', 'emerald', 'blue_gray', 'goldenrod', 'azure' ].map { |c| c = [ c.humanize, c ] }
    end

  private

    def super_admin_only
      redirect_to root_path, notice: 'You are not authorized to view that page.' unless current_user.super_admin?
    end

  end
end
