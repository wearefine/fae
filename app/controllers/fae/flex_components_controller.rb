module Fae
  class FlexComponentsController < Fae::NestedBaseController

    def new
      Rails.logger.info '---------------------'
      Rails.logger.info params
      @item = @klass.new({
        flex_componentable_type: params[:item_class],
        flex_componentable_id: params[:item_id],
        component_model: params[:component]
      })
  
      if @item.save
        component = @item.component_model.constantize.new
        component.save(validate: false)
        @item.update(component_id: component.id)
  
        @parent_item = @item.flex_componentable
        flash.now[:notice] = t('fae.save_notice')
        redirect_to "/admin/#{component.class.to_s.underscore.pluralize}/#{component.id}/edit"
        # render partial: 'fae/shared/flex_components_table', locals: {assoc: :flex_components, parent_item: @parent_item, initial_create: true}
      else
        build_assets
        render action: 'new'
      end
    end
  
    def create
      Rails.logger.info '---------------------'
      Rails.logger.info params
      raise up
      @item = @klass.new(permitted_params)
  
      if @item.save
        component = @item.component_model.constantize.new
        component.save(validate: false)
        @item.update(component_id: component.id)
  
        @parent_item = @item.flex_componentable
        flash.now[:notice] = t('fae.save_notice')
        render partial: 'fae/shared/flex_components_table', locals: {assoc: :flex_components, parent_item: @parent_item, initial_create: true}
      else
        build_assets
        render action: 'new'
      end
    end
  
    def destroy
      @parent_item = @item.flex_componentable
  
      if @item.destroy
        flash.now[:notice] = t('fae.delete_notice')
      else
        flash.now[:alert] = t('fae.delete_error')
      end
      render partial: 'fae/shared/flex_components_table', locals: {assoc: :flex_components, parent_item: @parent_item}
    end

    private

    def set_class_variables
      @klass_name = 'Fae::FlexComponent'
      @klass = @klass_name.classify.constantize
      @klass_singular = @klass_name.singularize
    end
  
    # only allow trusted parameters, override to white-list
    def permitted_params
      params.require('flex_component').permit!
    end

  end  
end