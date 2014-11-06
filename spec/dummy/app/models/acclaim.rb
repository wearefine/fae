class Acclaim < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  def fae_display_field
    publication
  end

  belongs_to :release
end