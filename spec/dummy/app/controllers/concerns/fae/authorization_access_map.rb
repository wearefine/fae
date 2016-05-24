module Fae
  module AuthorizationAccessMap
    extend ActiveSupport::Concern

    def self.access_map
      {
        'teams' => ['super admin', 'admin']
      }
    end

  end
end
