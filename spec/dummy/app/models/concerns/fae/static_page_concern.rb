module Fae
  module StaticPageConcern
    extend ActiveSupport::Concern

    def instance_says_what
      'Fae::StaticPage instance: what?'
    end

    module ClassMethods
      def class_says_what
        'Fae::StaticPage class: what?'
      end
    end

  end
end