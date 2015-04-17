class Release < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  def fae_display_field
    name
  end

  validates :name, presence: true, length: {in: 3..15}, uniqueness: true, exclusion: %w(admin danny)
  validates :price, numericality: {greater_than: 12}, allow_blank: true
  validates :video_url, format: /[a-zA-Z0-9_-]{11}/, allow_blank: true
  validates :wine_id, presence: true
  validates :intro, length: { maximum: 100 }
  validates :release_date, presence: true

  belongs_to :wine
  belongs_to :varietal

  has_many :acclaims
  has_many :aromas

  has_many :release_selling_points
  has_many :selling_points, through: :release_selling_points
  accepts_nested_attributes_for :release_selling_points

  has_many :event_releases
  has_many :events, through: :event_releases

  has_one :bottle_shot, as: :imageable, class_name: '::Fae::Image', dependent: :destroy
  accepts_nested_attributes_for :bottle_shot, allow_destroy: true

  has_one :label_pdf, as: :fileable, class_name: '::Fae::File', dependent: :destroy
  accepts_nested_attributes_for :label_pdf, allow_destroy: true

end
