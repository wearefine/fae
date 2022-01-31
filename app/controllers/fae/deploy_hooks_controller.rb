module Fae
  class DeployHooksController < ApplicationController
    before_action :super_admin_only
    before_action :set_deploy_hook, only: [:show, :edit, :update, :destroy]
    before_action :set_index_path, only: [:new, :edit]

    def index
      @deploy_hooks = Fae::DeployHook.all
    end

    def new
      @deploy_hook = Fae::DeployHook.new
    end

    def edit
    end

    def create
      @deploy_hook = Fae::DeployHook.new(deploy_hook_params)

      if @deploy_hook.save
        redirect_to deploy_hooks_path, notice: t('fae.save_notice')
      else
        render action: 'new', error: t('fae.save_error')
      end
    end

    def update
      if @deploy_hook.update(deploy_hook_params)
        redirect_to deploy_hooks_path, notice: t('fae.save_notice')
      else
        render action: 'edit', error: t('fae.save_error')
      end
    end

    def destroy
      @deploy_hook.destroy
      respond_to do |format|
        format.html { redirect_to deploy_hooks_url }
        format.json { head :no_content }
      end
    end

    private

      def set_deploy_hook
        @deploy_hook = Fae::DeployHook.find(params[:id])
      end

      def deploy_hook_params
        params.require(:deploy_hook).permit!
      end

      def set_index_path
        # @index_path determines form's cancel btn path
        @index_path = deploy_hooks_path
      end

  end
end