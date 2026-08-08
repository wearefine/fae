class Widget < ApplicationRecord
  include Fae::BaseModelConcern
  include Livable



  acts_as_list add_new_at: :top
  default_scope { order(:position) }

  def fae_display_field
    name
  end

end
