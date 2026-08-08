module Admin
  class ZigZagItemsController < Fae::NestedBaseController
    include Fae::InertiaNestedRenderable

    def self.fae_form_fields
      [
        {
          section: {
            title: 'Main',
            fields: [
              { name: :heading, type: :text },
              { name: :image, type: :image },
              { name: :body, type: :textarea, markdown: true },
              { name: :on_stage, type: :checkbox },
              { name: :on_prod, type: :checkbox }
            ]
          }
        }
      ]
    end



    private

    def build_assets
      @item.build_image if @item.image.blank?
    end

    def fae_inertia_parent_path(item, open_row: false)
      component = item.zig_zag_component
      flex = component&.flex_component
      owner = flex&.flex_componentable
      return super if owner.blank?

      options = {}
      if open_row
        options[:open_flex_component_id] = flex.id
        options[:open_nested_assoc] = 'zig_zag_items'
        options[:open_nested_row_id] = item.id
      end
      options[:draft] = true if params[:draft] == 'true'
      main_app.polymorphic_path([:edit, :admin, owner], options)
    end

  end
end