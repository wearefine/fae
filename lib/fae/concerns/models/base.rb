module Fae::Concerns::Models::Base
  extend ActiveSupport::Concern

  module ClassMethods
    def for_admin_index
      all
    end
  end
end