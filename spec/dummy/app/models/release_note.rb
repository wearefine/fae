class ReleaseNote < ActiveRecord::Base
  include Fae::BaseModelConcern

  belongs_to :release, touch: true

  def fae_nested_parent
    :release
  end

  def fae_display_field
    title
  end

  def fae_tracker_parent
    # has to be an AR object
    release
  end

  acts_as_list add_new_at: :top
  default_scope { order(:position) }

end
