module Fae
  class Change < ActiveRecord::Base
    belongs_to :user
  end
end
