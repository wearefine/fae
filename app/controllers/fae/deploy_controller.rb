module Fae
  class DeployController < ApplicationController
    before_action :admin_only

    def index
      raise 'Fae.netlify configs are missing.' if Fae.netlify.blank?
      @deploy_hooks = DeployHook.all
    end

    def deploys_list
      render json: Fae::NetlifyApi.new().get_deploys
    end

    def deploy_site
      if Fae::NetlifyApi.new().run_deploy(params['deploy_hook_type'], current_user)
        return render json: { success: true }
      end
      render json: {success: false}
    end

  end
end
