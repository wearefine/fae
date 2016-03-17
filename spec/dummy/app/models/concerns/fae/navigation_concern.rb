module Fae
  module NavigationConcern
    extend ActiveSupport::Concern

    def structure
      [
        item('Wines', subitems: [
          item('Wines', class: 'custom-class', subitems: wine_subitems),
          item('Releases', path: admin_releases_path),
          item('Attributes', subitems: [
            item('Varietals', path: admin_varietals_path),
            item('Selling Points', path: admin_selling_points_path)
          ])
        ]),
        item('Events', subitems: [
          item('Events', path: admin_events_path),
          item('Event Hosts', path: admin_people_path),
          item('Locations', path: admin_locations_path)
        ]),
        item('Other Stuff', subitems: [
          item('Teams', subitems: team_subitems),
          item('Look This Drawer Does Nothing', subitems: [
            item('Except Go To a Sidenav', subitems: [
              item('With a link That Goes Nowhere', path: 'nowhere')
            ])
          ]),
          item('Cats', path: admin_cats_path),
          item('Validation Testers', path: admin_validation_testers_path),
        ]),
        item('Pages', subitems: [
          item('Home', path: fae.edit_content_block_path('home')),
          item('About Us', path: fae.edit_content_block_path('about_us'))
        ])
      ]
    end

    private

    def wine_subitems
      wines_arr = [ item('New Wine', path: new_admin_wine_path) ]
      Wine.all.each do |wine|
        wines_arr << item(wine.name_en, path: edit_admin_wine_path(wine))
      end
      wines_arr
    end

    def team_subitems
      teams_arr = []
      Team.order(:name).each do |team|
        teams_arr << item(team.name, subitems: [
          item('Coaches', path: admin_team_coaches_path(team)),
          item('Players', path: admin_team_players_path(team))
        ])
      end
      teams_arr << item('Edit Teams', path: admin_teams_path)
    end
  end
end
