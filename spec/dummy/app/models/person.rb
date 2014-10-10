class Person < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  has_one :image, as: :imageable, class_name: '::Fae::Image', dependent: :destroy
  accepts_nested_attributes_for :image, allow_destroy: true

  belongs_to :event
end