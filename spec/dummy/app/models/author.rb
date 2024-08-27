class Author < ApplicationRecord
  include Fae::BaseModelConcern
        
  belongs_to :article, touch: true

  validates :name_en, presence: true

  fae_translate :name

  def fae_nested_parent
    :article
  end

  def fae_display_field
    name_en
  end

  def self.for_fae_index
    order(:name_en)
  end

end
