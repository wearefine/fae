class PolyThing < ApplicationRecord
  include Fae::BaseModelConcern

  belongs_to :poly_thingable, polymorphic: true

  has_fae_image :image

  validates :name_en, presence: true

  def fae_nested_parent
    :poly_thingable
  end

  def fae_display_field
    name_en
  end

  class << self

    def for_fae_index
      order(:name_en)
    end

  end

end
