class ArticleCategory < ApplicationRecord
  include Fae::BaseModelConcern

  attr_accessor :on_stage

  acts_as_list add_new_at: :top
  default_scope { order(:position) }

  has_many :articles

  validates :name, presence: true

  def fae_display_field
    name
  end

end
