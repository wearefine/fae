class TextComponent < ApplicationRecord
  include Fae::BaseModelConcern
  def fae_display_field
    name
  end
  include Fae::BaseFlexComponentConcern
  has_flex_component name


end
