module Fae
  module UserConcern
    extend ActiveSupport::Concern

    module ClassMethods
      # add more languages for your users
      def available_languages
        [:en]
      end
    end
  end
end
