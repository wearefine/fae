class Winemaker < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  belongs_to :wine, touch: true

  acts_as_list add_new_at: :top
  default_scope { order(:position) }

  has_one :winemaker_image, as: :imageable, class_name: '::Fae::Image', dependent: :destroy
  accepts_nested_attributes_for :winemaker_image, allow_destroy: true

  validates :name, presence: true

  def table_image
    # used as a custom method for the table view, displays an image in the table based on some logic
    winemaker_image if name.present?
  end

  def fae_display_field
    name
  end

  def association_type
    if region_type == 1
      :oregon_winemakers
    elsif region_type == 2
      :california_winemakers
    end
  end

end
