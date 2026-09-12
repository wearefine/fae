module Fae
  module NavigationConcern
    extend ActiveSupport::Concern

    def structure
      [
        item('Wines', path: admin_wines_path),
        item('Releases', path: admin_releases_path),
        item('Beers', path: admin_beers_path),
        item('Press', subitems: [
          item('Articles', path: admin_articles_path),
          item('Article Categories', path: admin_article_categories_path),
        ]),
        item('Pages', path: edit_admin_privacy_page_path, subitems: [
          item('Privacy', path: edit_admin_privacy_page_path),
          item('Intro Page', path: edit_admin_intro_page_path),
        ]),
        item('Spirits', path: admin_spirits_path),
        item('Widgets', path: admin_widgets_path),
        item('Cars', path: admin_cars_path),
        item('Car Categories', path: admin_car_categories_path),
        item('Trucks', path: admin_trucks_path),
        # scaffold inject marker
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
