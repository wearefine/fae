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

  def fae_display_field
    component_instance.fae_display_field
  end

  def destroy_associated_component
    component_instance.destroy
  end

  def preview_image_url

  end

  class << self

    def base_components
      [

        # base component inject marker
      ]
    end

    # Including this as an example of how to conditionally include components based on the model
    def page_components
      []
    end

    def components_for(model)
      ret = base_components
      ret += page_components if model == 'Fae::StaticPage'
      ret.sort.collect{ |c| [c.titleize.gsub('Component',''), c] }
    end

  end

end