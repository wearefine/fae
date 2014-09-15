class Release < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  belongs_to :wine
  belongs_to :varietal

  has_many :acclaims

  has_many :release_selling_points
  has_many :selling_points, through: :release_selling_points
  accepts_nested_attributes_for :release_selling_points

  has_many :event_releases
  has_many :events, through: :event_releases

end
