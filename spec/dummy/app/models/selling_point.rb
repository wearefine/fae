class SellingPoint < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  has_many :release_selling_points
  has_many :releases, through: :release_selling_points
end
