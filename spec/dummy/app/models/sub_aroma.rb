class SubAroma < ApplicationRecord
  include Fae::BaseModelConcern

  belongs_to :aroma, touch: true

  default_scope { order(:name) }

  def fae_nested_parent
    :aroma
  end

  def fae_display_field
    name
  end

  class << self

    def for_fae_index
      order(:name)
    end

  end

end
