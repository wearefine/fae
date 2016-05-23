module Fae
  module Nanny
    extend ActiveSupport::Concern

    private

    def babysit
      roles_for_controller = Fae::NannyAbilities::access_map[params[:controller].gsub('admin/','')]
      return if current_user.super_admin? || roles_for_controller.blank?
      return show_404 unless roles_for_controller.include?(current_user.role_id)
    end

  end
end
