class BeerAroma < ApplicationRecord
  include Fae::BaseModelConcern

  belongs_to :beer
  belongs_to :aroma

  acts_as_list scope: :beer

  default_scope { order(:position) }

  def fae_display_field
    aroma&.name
  end
end
