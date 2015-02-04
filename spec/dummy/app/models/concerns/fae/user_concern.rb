module Fae
  module UserConcern
    extend ActiveSupport::Concern

    def instance_says_what
      'Fae::User instance: what?'
    end

    module ClassMethods
      def class_says_what
        'Fae::User class: what?'
      end
    end

  end
end