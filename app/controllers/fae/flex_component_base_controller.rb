module Fae
  class FlexComponentBaseController < Fae::NestedBaseController
    include Fae::InertiaNestedRenderable

    def self.fae_form_fields
      []
    end

    def self.fae_nested_tables
      []
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