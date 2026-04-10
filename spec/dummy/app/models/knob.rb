class Knob < ApplicationRecord
  include Fae::BaseModelConcern
  def fae_display_field
    title
  end

  include Fae::BaseFlexComponentConcern

end
