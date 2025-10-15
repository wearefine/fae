module Fae
  class NestedBaseController < Fae::ApplicationController

    before_action :set_class_variables
    before_action :set_item, only: [:show, :edit, :update, :destroy]

    layout false, except: :index
    helper Fae::ApplicationHelper

    def new
      @item = @klass.new
      raise_undefined_parent if @item.fae_nested_foreign_key.blank?

      item_id = params[:item_id].to_i || nil
      @item.send("#{parent_foreign_key}=", item_id)
      build_assets
    end

    def edit
      build_assets
    end

    def create
      @item = @klass.new(permitted_params)
      raise_undefined_parent if @item.fae_nested_parent.blank?

      if @item.save
        @parent_item = @item.send(nested_parent)
        flash.now[:notice] = t('fae.save_notice')
        render template: table_template_path
      else
        build_assets
        render action: 'new'
      end
    end

    def update
      raise_undefined_parent if @item.fae_nested_parent.blank?

      if @item.update(permitted_params)
        @parent_item = @item.send(nested_parent)
        flash.now[:notice] = t('fae.save_notice')
        render template: table_template_path
      else
        build_assets
        render action: 'edit'
      end
    end

    def destroy
      raise_undefined_parent if @item.fae_nested_parent.blank?
      @parent_item = @item.send(nested_parent)

      if @item.destroy
        flash.now[:notice] = t('fae.delete_notice')
      else
        flash.now[:alert] = t('fae.delete_error')
      end
      render template: table_template_path
    end

    private

    def set_class_variables
      @klass_name = params[:controller].split('/').last
      @klass = @klass_name.classify.constantize
      @klass_singular = @klass_name.singularize
    end

    def set_item
      @item = @klass.find(params[:id])
    end

    # only allow trusted parameters, override to white-list
    def permitted_params
      params.require(@klass_singular).permit!
    end

    # if model has images or files, build them here for nesting
    def build_assets
    end

    def raise_undefined_parent
      raise "Define `fae_nested_parent` as a instance method of #{@klass.name}"
    end

    def table_template_path
      "#{fae.root_path.gsub('/', '')}/#{@klass_name}/table"
    end

    def parent_foreign_key
      @item.fae_nested_foreign_key
    end

    def nested_parent
      @item.fae_nested_parent
    end

  end
end
