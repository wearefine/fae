class Aroma < ActiveRecord::Base
  belongs_to :release

  default_scope { order(:position) }

  has_one :image, as: :imageable, class_name: '::Fae::Image', dependent: :destroy
  accepts_nested_attributes_for :image, allow_destroy: true
end
