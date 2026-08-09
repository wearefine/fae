class CarCategory < ApplicationRecord
  include Fae::BaseModelConcern
  include Livable

  has_many :cars

  has_fae_image :image

  acts_as_list add_new_at: :top
  default_scope { order(:position) }

  validates :name, presence: true

  def fae_display_field
    name
  end

end
