class Player < ActiveRecord::Base
  include Fae::BaseModelConcern

  belongs_to :team

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :team_id, presence: true

  def fae_display_field
    full_name
  end

  def fae_parent
    team
  end

  def full_name
    "#{first_name} #{last_name}"
  end

end
