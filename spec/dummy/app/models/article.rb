class Article < ApplicationRecord
  include Fae::BaseModelConcern

  acts_as_list add_new_at: :top
  default_scope { order(:position) }

  belongs_to :article_category

  validates :title, presence: true
  validates :article_category, presence: true

  def fae_display_field
    title
  end
end
