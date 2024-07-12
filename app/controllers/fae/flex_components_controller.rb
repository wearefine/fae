module Fae
  class FlexComponentsController < Fae::NestedBaseController

    def new
      @item = @klass.new
      @item.flex_componentable_id = params[:item_id]
      @item.flex_componentable_type = params[:item_class]
      build_assets
    end
  
    def create
      @item = @klass.new(permitted_params)
  
      if @item.save
        component = @item.component_model.constantize.new
        component.save(validate: false)
        @item.update(component_id: component.id)
  
        @parent_item = @item.flex_componentable
        flash[:notice] = t('fae.save_notice')
        render partial: 'fae/shared/flex_components_table', locals: {assoc: :flex_components, parent_item: @parent_item, initial_create: true}
      else
        build_assets
        render action: 'new'
      end
    end
  
    def destroy
      @parent_item = @item.flex_componentable
  
      if @item.destroy
        flash[:notice] = t('fae.delete_notice')
      else
        flash[:alert] = t('fae.delete_error')
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