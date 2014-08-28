class Release < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  class << self
    def for_admin_index
      order(:position)
    end
  end
end
