class Aroma < ActiveRecord::Base
  include Fae::BaseModelConcern

  belongs_to :release
  has_many :cats

  default_scope { order(:position) }

  has_one :image, as: :imageable, class_name: '::Fae::Image', dependent: :destroy
  accepts_nested_attributes_for :image, allow_destroy: true

  def fae_display_field
    name
  end

  def fae_tracker_blacklist
    'all'
  end

  def cat_size
    cats.size.to_s
  end
end
