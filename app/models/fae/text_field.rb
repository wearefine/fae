module Fae
  class TextField < ActiveRecord::Base
    belongs_to :contentable
  end
end
