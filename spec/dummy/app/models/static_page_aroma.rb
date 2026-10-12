class StaticPageAroma < ApplicationRecord
  acts_as_list add_new_at: :bottom, scope: :static_page
  default_scope { order(:position) }

  belongs_to :static_page, class_name: 'Fae::StaticPage', optional: true
  belongs_to :aroma, optional: true

  def fae_display_field
    aroma.fae_display_field
  end
end
