class ZigZagComponent < ApplicationRecord
  include Fae::BaseModelConcern
  include Fae::BaseFlexComponentConcern

  has_flex_component name

  has_many :zig_zag_items, dependent: :destroy

  validates :name, presence: true

  def fae_display_field
    name
  end

end
