module Fae
  module OptionConcern
    extend ActiveSupport::Concern

    def instance_says_what
      'Fae::Option instance: what?'
    end

    module ClassMethods
      def class_says_what
        'Fae::Option class: what?'
      end
    end

  end
end