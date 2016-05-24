module Fae
  module Authorization
    extend ActiveSupport::Concern

    private

    def authorize_user
      roles_for_controller = Fae::AuthorizationAccessMap::access_map[params[:controller].gsub('admin/','')]
      return if current_user.super_admin? || roles_for_controller.blank?
      return show_404 unless roles_for_controller.include?(current_user.role.name)
    end

  end
end
