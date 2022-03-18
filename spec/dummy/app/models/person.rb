class Person < ActiveRecord::Base
  include Fae::BaseModelConcern

  def fae_display_field
    name
  end

  has_one :image, as: :imageable, class_name: '::Fae::Image', dependent: :destroy
  accepts_nested_attributes_for :image, allow_destroy: true

  validates_presence_of :name

  belongs_to :event
end
