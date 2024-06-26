module Fae
  module BaseFlexComponentConcern
    extend ActiveSupport::Concern
  
    def parent_object
      flex_component.flex_componentable
    end
  
    def component_type_name
      self.class.name.titleize
    end
  
    module ClassMethods
  
      def has_flex_component(model_name)
        has_one :flex_component, -> { where('fae_flex_components.component_model' => model_name) },
                foreign_key: 'component_id', class_name: 'Fae::FlexComponent'
      end
  
    end
  
  end
end