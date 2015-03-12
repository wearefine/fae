class Team < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  has_many :coaches
  has_many :players

  validates :name, presence: true

  def fae_display_field
    name
  end

end
