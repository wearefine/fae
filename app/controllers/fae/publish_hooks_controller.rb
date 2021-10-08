module Fae
  class PublishHooksController < ApplicationController
    before_action :super_admin_only
    before_action :set_publish_hook, only: [:show, :edit, :update, :destroy]
    before_action :set_index_path, only: [:new, :edit]

    def index
      @publish_hooks = PublishHook.all
    end

    def new
      @publish_hook = Fae::PublishHook.new
    end

    def edit
    end

    def create
      @publish_hook = Fae::PublishHook.new(publish_hook_params)

      if @publish_hook.save
        redirect_to publish_hooks_path, notice: t('fae.save_notice')
      else
        render action: 'new', error: t('fae.save_error')
      end
    end

    def update
      if @publish_hook.update(publish_hook_params)
        redirect_to publish_hooks_path, notice: t('fae.save_notice')
      else
        render action: 'edit', error: t('fae.save_error')
      end
    end

    def destroy
      @publish_hook.destroy
      respond_to do |format|
        format.html { redirect_to publish_hooks_url }
        format.json { head :no_content }
      end
    end

    private

      def set_publish_hook
        @publish_hook = Fae::PublishHook.find(params[:id])
      end

      def publish_hook_params
        params.require(:publish_hook).permit!
      end

      def set_index_path
        # @index_path determines form's cancel btn path
        @index_path = publish_hooks_path
      end

  end
end
