module Fae
  class FlexComponent < ApplicationRecord
    include Fae::BaseModelConcern
    include Fae::FlexComponentConcern
  
    before_destroy :destroy_associated_component
  
    acts_as_list add_new_at: :bottom, scope: [:flex_componentable_type, :flex_componentable_id]
    default_scope { order(:position) }
  
    belongs_to :flex_componentable, polymorphic: true
  
    validates :component_model, presence: true
  
    def component_instance
      component_model.classify.constantize.find_by_id(component_id)
    end
  
    def component_model_human
      component_instance.component_type_name.gsub('Component','')
    end
  
    def destroy_associated_component
      component_instance.destroy
    end
  
  end
end