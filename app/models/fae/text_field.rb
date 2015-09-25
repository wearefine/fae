module Fae
  class TextField < ActiveRecord::Base
    include Fae::TextFieldConcern
    include Fae::PageValidatable

    belongs_to :contentable, polymorphic: true, touch: true
  end
end
