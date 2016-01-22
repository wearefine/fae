class Wine < ActiveRecord::Base
  include Fae::Concerns::Models::Base
  has_many :release
  has_many :winemakers

  validates :name_en, :name_zh, :name_ja, presence: true

  # def active_model_serializer
  #   WineSerializer
  # end

  def fae_display_field
    name_en
  end

  def self.for_fae_index
    order(:name_en)
  end

end
