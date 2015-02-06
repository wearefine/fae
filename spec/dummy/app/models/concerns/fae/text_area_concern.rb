module Fae
  module TextAreaConcern
    extend ActiveSupport::Concern

    def instance_says_what
      'Fae::TextArea instance: what?'
    end

    module ClassMethods
      def class_says_what
        'Fae::TextArea class: what?'
      end
    end

  end
end