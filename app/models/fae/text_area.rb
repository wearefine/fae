module Fae
  class TextArea < ActiveRecord::Base
    include Fae::TextAreaConcern

    belongs_to :contentable, polymorphic: true, touch: true
  end
end
