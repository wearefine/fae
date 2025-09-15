module Fae
  class OptionsController < ApplicationController

    before_action :super_admin_only

    def edit
      @option = Option.first || Option.instance
      @option.build_logo if @option.logo.blank?
      @option.build_favicon if @option.favicon.blank?
      @deploy_hooks = DeployHook.all
    end

    # PATCH/PUT /options/1
    def update
      if @option.update(option_params)
        if @option.previous_changes.include?('site_mfa_enabled')
          Fae::User.update_mfa(option_params['site_mfa_enabled'], current_user.email)
        end
        flash[:notice] = 'Option was successfully updated.'
        redirect_to :action => :edit
      else
        render :edit
      end
    end

    private

      # Only allow a trusted parameter "white list" through.
      def option_params
        params.require(:option).permit(:title, :time_zone, :colorway, :site_mfa_enabled, :stage_url, :live_url, logo_attributes: [:id, :asset, :asset_cache, :attached_as, :alt], favicon_attributes: [:id, :asset, :asset_cache, :attached_as, :alt])
      end
  end
end
