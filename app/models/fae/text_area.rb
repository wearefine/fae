module Fae
  class TextArea < ActiveRecord::Base
    include Fae::TextAreaConcern
    include Fae::PageValidatable

    belongs_to :contentable, polymorphic: true, touch: true
  end
end
