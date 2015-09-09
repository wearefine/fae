require_relative 'base_generator'
module Fae
  class NestedIndexScaffoldGenerator < Fae::BaseGenerator
    source_root File.expand_path('../templates', __FILE__)

    def go
      generate_model
      generate_nested_index_controller_file
      inject_display_field_to_model
      generate_view_files
      add_route
      inject_nav_item
    end


    private

      def generate_nested_index_controller_file
        template "controllers/nested_index_scaffold_controller.rb", "app/controllers/#{options.namespace}/#{file_name.pluralize}_controller.rb"
      end

  end
end