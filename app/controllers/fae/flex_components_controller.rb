module Fae
  class FlexComponentsController < Fae::NestedBaseController

    def new
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
        redirect_to "/admin/#{component.class.to_s.underscore.pluralize}/#{component.id}/edit?draft=true"
      else
        build_assets
        render action: 'new'
      end
    end
  
    def create
      @item = @klass.new(permitted_params)
  
      if @item.save
        component = @item.component_model.constantize.new
        component.save(validate: false)
        @item.update(component_id: component.id)
  
        @parent_item = @item.flex_componentable
        redirect_to fae_inertia_flex_parent_path(@parent_item, open_flex_component_id: @item.id), notice: t('fae.save_notice')
      else
        build_assets
        redirect_to fae_inertia_flex_parent_path(@item.flex_componentable), flash: { alert: t('fae.save_error') }
      end
    end
  
    def destroy
      @parent_item = @item.flex_componentable
  
      if @item.destroy
        redirect_to fae_inertia_flex_parent_path(@parent_item), notice: t('fae.delete_notice')
      else
        redirect_to fae_inertia_flex_parent_path(@parent_item), flash: { error: t('fae.delete_error') }
      end
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

    def fae_inertia_flex_parent_path(parent, extra = {})
      return fae.root_path if parent.blank?

      options = {}
      options[:draft] = true if params[:draft] == 'true'
      options.merge!(extra)
      main_app.polymorphic_path([:edit, :admin, parent], options)
    end

  end  
end