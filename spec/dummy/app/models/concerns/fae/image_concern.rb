module Fae
  module ImageConcern
    extend ActiveSupport::Concern

    def instance_says_what
      'Fae::Image instance: what?'
    end

    module ClassMethods
      def class_says_what
        'Fae::Image class: what?'
      end
    end

  end
end