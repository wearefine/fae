class Cat < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  belongs_to :aroma

  def fae_display_field
    name
  end

end
