module Fae
  class DeployController < ApplicationController
    before_action :admin_only

    include Fae::ApplicationHelper

    def index
      raise 'Fae deploy configs are missing.' unless deploys_enabled?
      @deploy_hooks = DeployHook.all
    end

    def deploys_list
      render json: deploy_adapter.new().get_deploys
    end

    def deploy_site
      if deploy_adapter.new().run_deploy(params['deploy_hook_type'], current_user)
        return render json: { success: true }
      end
      render json: {success: false}
    end

    private

    def deploy_adapter
      case Fae.deploys_to
      when 'Cloudflare'
        CloudflareApi
      when 'Netlify'
        NetlifyApi
      end
    end

  end
end
