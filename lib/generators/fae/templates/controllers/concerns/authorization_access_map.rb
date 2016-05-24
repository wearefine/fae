module Fae
  module AuthorizationAccessMap
    extend ActiveSupport::Concern

    # mapping of controller name as it appears in params minus the base 'admin/' namespace part, mapped to the roles that can use it
    # please include any further namespacing as illustrated in 'asset_manager/tiers' below.
    def self.access_map
      {
      #  'teams' => ['super admin', 'admin'],
      #  'asset_manager/tiers' => ['super admin', 'admin']
      }
    end

  end
end
