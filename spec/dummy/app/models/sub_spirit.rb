class SubSpirit < ApplicationRecord
  include Fae::BaseModelConcern
    
  has_fae_cta :tout_cta

  belongs_to :spirit

  validates :name, presence: true

  def fae_display_field
    name
  end

  def fae_nested_parent
    :spirit
  end

end
