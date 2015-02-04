module Fae
  module NavItems
    extend ActiveSupport::Concern

    def nav_items
      [
        {
          text: 'Releases', path: '/admin/releases'
        },
        {
          text: 'Wines Dropdown', path: '#', sublinks: [
            { text: 'Wines', path: '/admin/wines' }
          ]
        },
        {
          text: 'Acclaim', path: '/admin/acclaims'
        },
        {
          text: 'Varietal', path: '/admin/varietals'
        },
        {
          text: 'Selling Point', path: '/admin/selling_points'
        },
        {
          text: 'Event', path: '/admin/events'
        },
        {
          text: 'Event Hosts', path: '/admin/people'
        },
        {
          text: 'Locations', path: '/admin/locations'
        },
        {
          text: 'Pages', path: '/admin/pages'
        }
      ]
    end

  end
end
