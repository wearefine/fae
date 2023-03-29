class Varietal < ActiveRecord::Base
  include Fae::BaseModelConcern

  def fae_display_field
    name
  end

  has_many :release
end
