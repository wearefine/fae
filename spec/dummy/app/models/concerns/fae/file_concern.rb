module Fae
  module FileConcern
    extend ActiveSupport::Concern

    def instance_says_what
      'Fae::File instance: what?'
    end

    module ClassMethods
      def class_says_what
        'Fae::File class: what?'
      end
    end

  end
end