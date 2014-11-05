class Varietal < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  def display_field
    name
  end

  has_many :release
end
