module Fae
  module UserConcern
    extend ActiveSupport::Concern
    module ClassMethods
      def available_languages
        [:en]
      end
    end
  end
end
