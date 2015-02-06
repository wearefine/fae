module Fae
  module RoleConcern
    extend ActiveSupport::Concern

    def instance_says_what
      'Fae::Role instance: what?'
    end

    module ClassMethods
      def class_says_what
        'Fae::Role class: what?'
      end
    end

  end
end