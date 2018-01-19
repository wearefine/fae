class Aroma < ActiveRecord::Base
  include Fae::BaseModelConcern

  belongs_to :release
  has_many :cats

  acts_as_list add_new_at: :top, scope: :release
  default_scope { order(:position) }

  has_one :image, as: :imageable, class_name: '::Fae::Image', dependent: :destroy
  accepts_nested_attributes_for :image, allow_destroy: true

  validates :name, presence: true

  def fae_display_field
    name
  end

  def fae_tracker_blacklist
    'all'
  end

  def fae_nested_parent
    :release
  end

  def cat_size
    cats.size.to_s
  end
end
