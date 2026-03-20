class ArticleSubcategory < ApplicationRecord
  include Fae::BaseModelConcern
        
  belongs_to :article_category, touch: true
  
  validates :name, presence: true

  def fae_nested_parent
    :article_category
  end
  
  def fae_display_field
    name
  end

end
