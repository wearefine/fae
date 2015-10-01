module Fae
  class Change < ActiveRecord::Base

    belongs_to :user
    belongs_to :changeable, polymorphic: true

    serialize :updated_attributes

    # writing current_user to thread for thread safety
    class << self
      def current_user=(user)
        Thread.current[:current_user] = user
      end

      def current_user
        Thread.current[:current_user]
      end
    end
  end
end
