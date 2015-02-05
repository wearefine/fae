module Fae
  module NavItems
    extend ActiveSupport::Concern

    # returns an array of hashes to build navigation in Fae's application_controller
    #
    # - prefix application named routes with `main_app.`
    # - prefix Fae names routes with `fae.`
    # - do not include dashboard or admin nav items
    #
    # format:
    #   { text: 'Cities', path: main_app.admin_cities_path, class: 'if-you-want' },
    #   {
    #     text: 'Items with subnav', sublinks: {
    #       text: 'Item Sublink 1', path: main_app.admin_some_path,
    #       text: 'Item Sublink 2', path: main_app.admin_someother_path
    #     }
    #   },
    #   { text: 'Pages', path: fae.pages_path }
    def nav_items
      [
      ]
    end

  end
end
