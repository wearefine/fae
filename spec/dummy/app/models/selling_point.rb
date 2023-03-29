class SellingPoint < ActiveRecord::Base
  include Fae::BaseModelConcern

  def fae_display_field
    name
  end

  has_many :release_selling_points
  has_many :releases, through: :release_selling_points
end
