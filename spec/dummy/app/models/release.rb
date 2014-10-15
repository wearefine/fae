class Release < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  validates :name, presence: true, length: {in: 3..14}
  validates :name, exclusion: %w(admin danny)
  validates :price, numericality: {greater_than: 12}
  validates :video_url, format: /[a-zA-Z0-9_-]{11}/
  validates :wine_id, presence: true

  belongs_to :wine
  belongs_to :varietal

  has_many :acclaims

  has_many :release_selling_points
  has_many :selling_points, through: :release_selling_points
  accepts_nested_attributes_for :release_selling_points

  has_many :event_releases
  has_many :events, through: :event_releases

end
