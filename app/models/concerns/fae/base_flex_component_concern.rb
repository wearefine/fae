module Fae
  module BaseFlexComponentConcern
    extend ActiveSupport::Concern

    included do
      has_flex_component self.name

      after_commit :touch_parent_object
      def touch_parent_object
        parent_object.touch if parent_object.present?
      end
    end
  
    def parent_object
      flex_component&.flex_componentable
    end

    def fae_nested_parent
      :parent_object
    end
  
    def component_type_name
      self.class.name.titleize
    end

    def preview_image_url
      nil
    end
  
    module ClassMethods
  
      def has_flex_component(model_name)
        has_one :flex_component, -> { where('fae_flex_components.component_model' => model_name) },
                foreign_key: 'component_id', class_name: 'Fae::FlexComponent'
      end
  
    end
  
  end
end