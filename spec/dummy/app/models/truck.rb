class Truck < ApplicationRecord
  include Fae::BaseModelConcern
  has_fae_image :image

  def fae_display_field
    name
  end

end
