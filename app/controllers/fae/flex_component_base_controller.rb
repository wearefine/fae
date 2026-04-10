module Fae
  class FlexComponentBaseController < Fae::NestedBaseController

    def update
      if @item.update(permitted_params)
        @parent_item = @item.flex_component.flex_componentable
        
        flash.now[:notice] = t('fae.save_notice')
        render template: 'fae/shared/_flex_components_table', formats: :html, locals: { assoc: :flex_components, parent_item: @parent_item }
      else
        build_assets
        render action: 'edit'
      end
    end
  
  end
end