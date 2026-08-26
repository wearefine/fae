class SubListItem < ApplicationRecord
  include Fae::BaseModelConcern
  include Livable
        
  belongs_to :list_item, touch: true

  acts_as_list add_new_at: :bottom
  default_scope { order(:position) }

  validates :name, presence: true
  validates :body, presence: true, length: { maximum: 500 }

  def fae_nested_parent
    :list_item
  end

  def fae_display_field
    name
  end

end
