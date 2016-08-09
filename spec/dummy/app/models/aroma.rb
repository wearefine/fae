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

  ## might want another use case object because this one is testing the blacklist
  # def fae_tracker_blacklist
  #   'all'
  # end

  def fae_tracker_parent
    # has to be an AR object
    release
  end

  def fae_nested_parent
    :release
  end

  def cat_size
    cats.size.to_s
  end
end
