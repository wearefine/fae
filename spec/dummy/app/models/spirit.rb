class Spirit < ApplicationRecord
  include Fae::BaseModelConcern
  
  has_fae_cta :some_other_cta
  has_fae_cta :website_cta

  has_many :sub_spirits, dependent: :destroy

  def fae_display_field
    name
  end

end
