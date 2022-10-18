module Fae
  class DeployHooksController < ApplicationController

    before_action :super_admin_only
    before_action :set_deploy_hook, only: [:show, :edit, :update, :destroy]
    layout false

    def index
      @deploy_hooks = DeployHook.all
    end

    def new
      @deploy_hook = DeployHook.new
    end

    def edit
    end

    def create
      @deploy_hook = DeployHook.new(deploy_hook_params)

      if @deploy_hook.save
        flash[:notice] = t('fae.save_notice')
        @deploy_hooks = DeployHook.all
        render partial: table_template_path
      else
        render action: 'new'
      end
    end

    def update
      if @deploy_hook.update(deploy_hook_params)
        flash[:notice] = t('fae.save_notice')
        @deploy_hooks = DeployHook.all
        render partial: table_template_path
      else
        render action: 'edit'
      end
    end

    def destroy
      if @deploy_hook.destroy
        flash[:notice] = t('fae.delete_notice')
      else
        flash[:alert] = t('fae.delete_error')
      end
      @deploy_hooks = DeployHook.all
      render partial: table_template_path
    end

    private

      def set_deploy_hook
        @deploy_hook = DeployHook.find(params[:id])
      end

      def deploy_hook_params
        params.require(:deploy_hook).permit!
      end

      def set_index_path
        # @index_path determines form's cancel btn path
        @index_path = deploy_hooks_path
      end

      def table_template_path
        "fae/deploy_hooks/table"
      end

  end
end