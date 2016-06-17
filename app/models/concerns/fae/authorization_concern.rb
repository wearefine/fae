module Fae
  module AuthorizationConcern
    extend ActiveSupport::Concern
    module ClassMethods

      def access_map
        {}
      end

    end
  end
end
