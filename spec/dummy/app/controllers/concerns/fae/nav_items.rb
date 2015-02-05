module Fae
  module NavItems
    extend ActiveSupport::Concern

    def nav_items
      [
        { text: 'Releases',       path: main_app.admin_releases_path },
        { text: 'Wines',          sublinks: wine_sublinks },
        { text: 'Acclaim',        path: main_app.admin_acclaims_path },
        { text: 'Varietal',       path: main_app.admin_varietals_path },
        { text: 'Selling Point',  path: main_app.admin_selling_points_path },
        { text: 'Event',          path: main_app.admin_events_path },
        { text: 'Event Hosts',    path: main_app.admin_people_path },
        { text: 'Locations',      path: main_app.admin_locations_path },
        { text: 'Pages',          path: fae.pages_path }
      ]
    end

    private

    def wine_sublinks
      wines_arr = [{ text: 'New Wine', path: main_app.new_admin_wine_path }]
      Wine.all.each do |wine|
        wines_arr << { text: wine.name, path: main_app.edit_admin_wine_path(wine) }
      end
      wines_arr
    end

  end
end
