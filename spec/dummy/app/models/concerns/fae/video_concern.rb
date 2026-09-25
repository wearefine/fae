module Fae
  module VideoConcern
    extend ActiveSupport::Concern

    def instance_says_what
      'Fae::Video instance: what?'
    end

    module ClassMethods
      def class_says_what
        'Fae::Video class: what?'
      end
    end

  end
end