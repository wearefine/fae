class Cat < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  def fae_display_field
    whiskers
  end

  def self.for_fae_index
    order(:whiskers)
  end

end
