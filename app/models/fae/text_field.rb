module Fae
  class TextField < ActiveRecord::Base
    belongs_to :contentable, polymorphic: true, touch: true
  end
end
