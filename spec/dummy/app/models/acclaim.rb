class Acclaim < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  def display_name
    publication
  end

  belongs_to :release
end