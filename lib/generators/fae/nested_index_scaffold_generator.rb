require_relative 'base_generator'
module Fae
  class NestedIndexScaffoldGenerator < Fae::BaseGenerator
    source_root ::File.expand_path('../templates', __FILE__)

    def go
      generate_model
      generate_graphql_type
      generate_nested_index_controller_file
      generate_view_files
      add_route
      inject_nav_item
    end


    private

      def generate_nested_index_controller_file
        @attachments = @@attachments
        template "controllers/nested_index_scaffold_controller.rb", "app/controllers/#{options.namespace}/#{file_name.pluralize}_controller.rb"
      end

      def generate_view_files
        @toggle_attrs = set_toggle_attrs
        @form_attrs = set_form_attrs
        @association_names = @@association_names
        @attachments = @@attachments
        @has_position = @@has_position
        @display_field = @@display_field
        template "views/index_nested.html.#{options.template}", "app/views/#{options.namespace}/#{plural_file_name}/index.html.#{options.template}"
        template "views/_form_index_nested.html.#{options.template}", "app/views/#{options.namespace}/#{plural_file_name}/_form.html.#{options.template}"
        template "views/new_nested.html.#{options.template}", "app/views/#{options.namespace}/#{plural_file_name}/new.html.#{options.template}"
        template "views/edit_nested.html.#{options.template}", "app/views/#{options.namespace}/#{plural_file_name}/edit.html.#{options.template}"
      end

  end
end
