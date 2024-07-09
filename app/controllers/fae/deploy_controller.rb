module Fae
  class DeployController < ApplicationController
    before_action :admin_only

    include Fae::ApplicationHelper

    def index
      raise 'Fae.netlify configs are missing.' unless netlify_enabled?
      if params[:site_id].present?
        @site = Site.find_by_id(params[:site_id])
        @deploy_hooks = @site.site_deploy_hooks
      else
        @deploy_hooks = DeployHook.all
      end
    end

    def deploys_list
      render json: Fae::NetlifyApi.new(params[:fae_site_id]).get_deploys
    end

    def deploy_site
      if Fae::NetlifyApi.new().run_deploy(params['deploy_hook_type'], current_user)
        return render json: { success: true }
      end
      render json: {success: false}
    end

  end
end
