module Fae
  class TextField < ActiveRecord::Base

    include Fae::BaseModelConcern
    include Fae::TextFieldConcern
    include Fae::PageValidatable

    belongs_to :contentable, polymorphic: true, touch: true

    def readonly?
      false
    end
  end
end
