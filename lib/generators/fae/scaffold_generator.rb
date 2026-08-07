require_relative 'base_generator'
module Fae
  class ScaffoldGenerator < Fae::BaseGenerator
    source_root ::File.expand_path('../templates', __FILE__)
    class_option :static_page, type: :boolean, default: false, desc: 'Generates a singleton static page resource (singular route + singleton controller record)'

    def go
      generate_model
      generate_graphql_type
      generate_controller_file
      add_route
      inject_nav_item
      inject_livable
    end

  end
end