module Fae
  module NavigationConcern
    extend ActiveSupport::Concern

    def structure
      [
        item('Products', subitems: [
          item('Wines', class: 'custom-class', path: admin_wines_path),
          item('Releases', path: admin_releases_path),
          item('Legacy Releases', path: admin_legacy_releases_path),
          item('Attributes', subitems: [
            item('Varietals', path: admin_varietals_path),
            item('Selling Points', path: admin_selling_points_path)
          ]),
          item('Cats', path: admin_cats_path)
        ]),
        item('Teams', subitems: team_subitems),
        item('Events', subitems: [
          item('Events', path: admin_events_path),
          item('Event Hosts', path: admin_people_path),
          item('Locations', path: admin_locations_path),
          item('Validation Testers', path: admin_validation_testers_path),
        ]),
        item('Pages', subitems: [
          item('Home', path: fae.edit_content_block_path('home')),
          item('About Us', path: fae.edit_content_block_path('about_us')),
          item('About Us', path: fae.edit_content_block_path('about_us')),
          item('About Us', path: fae.edit_content_block_path('about_us')),
          item('About Us', path: fae.edit_content_block_path('about_us')),
          item('About Us', path: fae.edit_content_block_path('about_us')),
          item('About Us', path: fae.edit_content_block_path('about_us')),
          item('About Us', path: fae.edit_content_block_path('about_us')),
          item('About Us', path: fae.edit_content_block_path('about_us')),
          item('About Us', path: fae.edit_content_block_path('about_us')),
          item('About Us', path: fae.edit_content_block_path('about_us')),
          item('About Us', path: fae.edit_content_block_path('about_us'))
        ])
      ]
    end

    private

    def team_subitems
      teams_arr = [ item('Team List', path: admin_teams_path) ]
      Team.order(:name).each do |team|
        teams_arr << item(team.name, subitems: [
          item('Personnel', subitems: [
            item('Coaches', path: admin_team_coaches_path(team)),
            item('Players', path: admin_team_players_path(team))
          ])
        ])
      end
      teams_arr
    end
  end
end
