require_relative 'base_generator'
module Fae
  class ScaffoldGenerator < Fae::BaseGenerator
    source_root File.expand_path('../templates', __FILE__)

    def go
      generate_model
      generate_controller_file
      generate_view_files
      add_route
    end

  end
end