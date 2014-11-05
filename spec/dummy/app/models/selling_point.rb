class SellingPoint < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  def display_field
    name
  end

  has_many :release_selling_points
  has_many :releases, through: :release_selling_points
end
