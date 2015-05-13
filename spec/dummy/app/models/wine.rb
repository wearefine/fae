class Wine < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  has_many :release

  validates :name_en, :name_zh, :name_ja, presence: true

  def fae_display_field
    name_en
  end

end
