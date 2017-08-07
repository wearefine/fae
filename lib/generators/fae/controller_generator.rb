require_relative 'base_generator'
module Fae
  class ControllerGenerator < Fae::BaseGenerator
    source_root ::File.expand_path('../templates', __FILE__)

    def go
      generate_controller_file
      generate_view_files
      add_route
    end

  end
end
