module Fae
  class FlexComponentBaseController < Fae::NestedBaseController
    include Fae::InertiaNestedRenderable

    def self.fae_form_fields
      []
    end

    def self.fae_nested_tables
      []
    end

    def update
      return super if request.inertia?

      if @item.update(permitted_params)
        @parent_item = @item.flex_component.flex_componentable
        
        flash.now[:notice] = t('fae.save_notice')
        render template: 'fae/shared/_flex_components_table', formats: :html, locals: { assoc: :flex_components, parent_item: @parent_item }
      else
        build_assets
        render action: 'edit'
      end
    end
    
    private

    def fae_inertia_parent_path(item, open_row: false)
      parent = item.parent_object
      return fae.root_path if parent.blank?

      options = {}
      options[:open_flex_component_id] = item.flex_component&.id if open_row
      options[:draft] = true if params[:draft] == 'true'
      main_app.polymorphic_path([:edit, :admin, parent], options)
    end
  
  end
end