module Fae
  class TextField < ActiveRecord::Base
    include Fae::TextFieldConcern

    belongs_to :contentable, polymorphic: true, touch: true
  end
end
