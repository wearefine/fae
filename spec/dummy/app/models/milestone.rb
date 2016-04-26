class Milestone < ActiveRecord::Base
  include Fae::BaseModelConcern

  def fae_display_field
    year
  end

end
