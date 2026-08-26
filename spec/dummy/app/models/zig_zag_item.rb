class ZigZagItem < ApplicationRecord
  include Fae::BaseModelConcern
  include Livable
        
  belongs_to :zig_zag_component, touch: true

  acts_as_list add_new_at: :bottom, scope: :zig_zag_component
  default_scope { order(:position) }

  has_fae_image :image

  validates :heading, presence: true

  def fae_nested_parent
    :zig_zag_component
  end

  def fae_display_field
    heading
  end

end
