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
        redirect_to @index_path, notice: "Success. You’ve done good."
      else
        build_assets
        render action: 'new', error: "Let’s slow down a bit. Check your form for errors."
      end
    end

    def update
      if @item.update(item_params)
        redirect_to @index_path, notice: "Success. You’ve done good."
      else
        build_assets
        render action: 'edit', error: "Let’s slow down a bit. Check your form for errors."
      end
    end

    def destroy
      if @item.destroy
        redirect_to @index_path, notice: 'Item was successfully removed'
      else
        redirect_to @index_path, flash: { error: 'This item has associated objects that prevent it from being removed.' }
      end
    end

  private

    def set_class_variables(class_name=nil)
      @klass_base = params[:controller].split('/').last
      @klass_name = class_name || @klass_base
      @klass = @klass_base.classify.constantize
      @klass_singular = @klass_name.singularize
      @klass_humanized = @klass_singular.humanize
      @index_path = '/'+params[:controller]
      @cancelled_path = @index_path+'?cancelled=true'
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
