module Fae
  module FlexComponentConcern
    extend ActiveSupport::Concern
    
    def instance_says_what
      'Fae::FlexComponent instance: what?'
    end

    module ClassMethods
      def class_says_what
        'Fae::FlexComponent class: what?'
      end
    end
  end
end