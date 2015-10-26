class Winemaker < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  def fae_display_field
    name
  end

  acts_as_list add_new_at: :top
  default_scope { order(:position) }

  belongs_to :wine, touch: true

end
