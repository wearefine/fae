class ListItem < ApplicationRecord
  include Fae::BaseModelConcern
  include Livable
        
  belongs_to :static_page, touch: true, class_name: 'Fae::StaticPage'

  acts_as_list add_new_at: :top
  default_scope { order(:position) }

  has_fae_image :image

  validates :name, presence: true
  validates :people, presence: true

  def fae_nested_parent
    :static_page
  end

  def fae_display_field
    name
  end

end
