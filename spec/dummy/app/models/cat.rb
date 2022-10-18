class Cat < ActiveRecord::Base
  include Fae::BaseModelConcern

  belongs_to :aroma

  def fae_display_field
    name
  end

  def lives
    9
  end

end
