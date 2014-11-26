module Fae
  class TextArea < ActiveRecord::Base
    belongs_to :contentable, polymorphic: true, touch: true
  end
end
