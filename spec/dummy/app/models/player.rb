class Player < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  def fae_display_field
    
  end

  belongs_to :team
end
