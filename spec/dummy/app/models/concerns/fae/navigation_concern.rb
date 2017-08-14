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
        item('Teams', path: admin_teams_path, subitems: team_subitems),
        item('Events', class_name: 'css-one-level-deep', subitems: [
          item('Event Hosts', path: admin_people_path, class_name: 'css-two-levels-deep'),
          item('Locations', path: admin_locations_path),
          item('Validation Testers', path: admin_validation_testers_path),
        ]),
        item('Press', subitems: [
          item('Articles', path: admin_articles_path),
          item('Article Categories', path: admin_article_categories_path),
        ]),
        item('Pages', path: fae.pages_path, subitems: [
          item('Home', path: fae.edit_content_block_path('home')),
          item('Contact Us', path: fae.edit_content_block_path('contact_us')),
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
      teams_arr = []
      Team.order(:name).each do |team|
        teams_arr << item(team.name, subitems: [
          item('Personnel', class_name: 'css-three-levels-deep', subitems: [
            item('Coaches', path: admin_team_coaches_path(team), class_name: 'css-four-levels-deep'),
            item('Players', path: admin_team_players_path(team))
          ]),
          item('Equipment', subitems: [
            item('Jerseys', path: admin_team_jerseys_path(team))
          ])
        ])
      end
      teams_arr
    end
  end
end
