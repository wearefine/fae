class Wine < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  has_many :release

  def fae_display_field
    name
  end

  def name
    name_en
  end
end
