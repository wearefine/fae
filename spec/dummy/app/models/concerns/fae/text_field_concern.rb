module Fae
  module TextFieldConcern
    extend ActiveSupport::Concern

    def instance_says_what
      'Fae::TextField instance: what?'
    end

    module ClassMethods
      def class_says_what
        'Fae::TextField class: what?'
      end
    end

  end
end