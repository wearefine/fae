module Fae
  class BaseController < ApplicationController

    before_action :set_class_variables
    before_action :set_item, only: [:edit, :update, :destroy]

    helper FormHelper

    def index
      @items = @klass.for_fae_index
    end

    def new
      @item = @klass.new
      build_assets
    end

    def edit
      build_assets
    end

    def create
      @item = @klass.new(item_params)

      if @item.save
        redirect_to @index_path, notice: t('fae.save_notice')
      else
        build_assets
        render action: 'new', error: t('fae.save_error')
      end
    end

    def update
      if @item.update(item_params)
        redirect_to @index_path, notice: t('fae.save_notice')
      else
        build_assets
        render action: 'edit', error: t('fae.save_error')
      end
    end

    def destroy
      if @item.destroy
        redirect_to @index_path, notice: t('fae.delete_notice')
      else
        redirect_to @index_path, flash: { error: t('fae.delete_error') }
      end
    end

  private

    def set_class_variables(class_name=nil)
      @klass_base = params[:controller].split('/').last
      @klass_name = class_name || @klass_base
      @klass = @klass_base.classify.constantize
      @klass_singular = @klass_base.singularize
      @klass_humanized = @klass_name.singularize.humanize
      @index_path = '/'+params[:controller]
      @new_path = @index_path+'/new'
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = @klass.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def item_params
      params.require(@klass_base.singularize).permit!
    end

    # if model has images or files, build them here for nesting
    def build_assets
    end

  end
end
