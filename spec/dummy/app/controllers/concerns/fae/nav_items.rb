module Fae
  module NavItems
    extend ActiveSupport::Concern

    def nav_items
      [
        { text: 'Releases',       path: admin_releases_path },
        { text: 'Wines',          sublinks: wine_sublinks },
        { text: 'Acclaim',        path: admin_acclaims_path },
        { text: 'Varietal',       path: admin_varietals_path },
        { text: 'Selling Point',  path: admin_selling_points_path },
        { text: 'Event',          path: admin_events_path },
        { text: 'Event Hosts',    path: admin_people_path },
        { text: 'Locations',      path: admin_locations_path },
        { text: 'Pages',          path: fae.pages_path }
      ]
    end

    private

    def wine_sublinks
      wines_arr = [{ text: 'New Wine', path: new_admin_wine_path }]
      Wine.all.each do |wine|
        wines_arr << { text: wine.name, path: edit_admin_wine_path(wine) }
      end
      wines_arr
    end

  end
end
