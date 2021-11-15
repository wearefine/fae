module Fae
  class PublishController < ApplicationController

    def index
      @publish_hooks = PublishHook.for_admin_environment
    end

    def deploys_list
      render partial: 'deploys_list', locals: { deploys: Fae::NetlifyApi.new().get_deploys }
    end

    def changes_list
      render partial: 'changes_list', locals: { changes: Fae::Change.since_last_deploy(params[:env]) }
    end

    def publish_site
      if Fae::NetlifyApi.new().run_deploy(params['publish_hook_id'], current_user)
        return render json: {
          success: true,
          last_successful_admin_deploy: Fae::NetlifyApi.new().last_successful_admin_deploy
        }
      end
      render json: {success: false}
    end

    def current_deploy
      render json: Fae::NetlifyApi.new().current_deploy
    end

    private

  end
end
