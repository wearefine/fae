class Winemaker < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  belongs_to :wine, touch: true

  acts_as_list add_new_at: :top
  default_scope { order(:position) }

  has_one :winemaker_image, as: :imageable, class_name: '::Fae::Image', dependent: :destroy
  accepts_nested_attributes_for :winemaker_image, allow_destroy: true

  def fae_display_field
    name
  end

end
