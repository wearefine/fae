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

      def available_languages
        [:en]
      end
    end

  end
end