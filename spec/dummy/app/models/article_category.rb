class ArticleCategory < ApplicationRecord
  include Fae::BaseModelConcern
  include FlexComponentableConcern

  acts_as_list add_new_at: :bottom
  default_scope { order(:position) }

  has_many :article_subcategories, dependent: :destroy

  has_many :articles

  validates :name, presence: true

  def fae_display_field
    name
  end

end
