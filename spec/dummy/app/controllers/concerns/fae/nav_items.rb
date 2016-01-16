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
        { text: 'Teams',          sublinks: team_sublinks },
        {
          text: 'Look This Drawer Does Nothing',
          sublinks: [
            {
              text: 'Except Open To Another Drawer',
              sublinks: [{ text: 'To A Link That Goes Nowhere' }]
            }
          ]
        },
        { text: 'Pages',          path: fae.pages_path },
        { text: 'Cats', path: main_app.admin_cats_path },
        { text: 'Validation Testers', path: main_app.admin_validation_testers_path },
        { text: 'To Be Destroyeds', path: main_app.admin_to_be_destroyeds_path },
        # scaffold inject marker
      ]
    end

    private

    def wine_sublinks
      wines_arr = [{ text: 'New Wine', path: main_app.new_admin_wine_path }]
      Wine.all.each do |wine|
        wines_arr << { text: wine.name_en, path: main_app.edit_admin_wine_path(wine) }
      end
      wines_arr
    end

    def team_sublinks
      teams_arr = []
      Team.order(:name).each do |team|
        teams_arr << {
          text: team.name,
          sublinks: [
            { text: 'Coaches', path: main_app.admin_team_coaches_path(team) },
            { text: 'Players', path: main_app.admin_team_players_path(team) }
          ]
        }
      end
      teams_arr << { text: 'Edit Teams', path: main_app.admin_teams_path }
    end

  end
end
