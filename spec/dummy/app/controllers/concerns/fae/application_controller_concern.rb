module Fae
  module ApplicationControllerConcern
    extend ActiveSupport::Concern

    def instance_says_what
      'Fae::ApplicationController instance: what?'
    end

    module ClassMethods
      def class_says_what
        'Fae::ApplicationController class: what?'
      end
    end

  end
end
