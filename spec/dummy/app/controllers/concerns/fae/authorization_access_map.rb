module Fae
  module AuthorizationAccessMap
    extend ActiveSupport::Concern

    def self.access_map
      {
        'people' => ['super admin', 'admin'],
        'locations' => ['super admin', 'admin'],
        'validation_testers' => ['super admin', 'admin'],
        'releases' => ['super admin', 'admin'],
        'selling_points' => ['super admin', 'admin'],
        'jerseys' => ['super admin', 'admin'],
        'content_blocks/about_us' => ['super admin']
      }
    end

  end
end
