module Fae
  class Role < ActiveRecord::Base
    has_many :users

    default_scope { order(:position) }
  end
end
