module Fae
  class PublishController < ApplicationController
    before_action :super_admin_only

    def index
    end

    def deploys_list
      render json: Fae::NetlifyApi.new().get_deploys
    end

    def changes_list
      render partial: 'changes_list', locals: { changes: Fae::Change.since_last_deploy(params[:env]) }
    end

    def publish_site
      if Fae::NetlifyApi.new().run_deploy(params['build_hook_type'], current_user)
        return render json: {
          success: true,
          last_successful_admin_deploy: Fae::NetlifyApi.new().last_successful_admin_deploy
        }
      end
      render json: {success: false}
    end

  end
end