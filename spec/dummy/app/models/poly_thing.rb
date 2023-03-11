class PolyThing < ApplicationRecord
  include Fae::BaseModelConcern

  belongs_to :poly_thingable, polymorphic: true

  validates :name, presence: true

  def fae_nested_parent
    :poly_thingable
  end

  def fae_display_field
    name
  end

  class << self

    def for_fae_index
      order(:name)
    end

  end

end
