require_relative 'base_generator'
module Fae
  class FlexComponentGenerator < Fae::BaseGenerator
    source_root ::File.expand_path('../templates', __FILE__)

    def go
      generate_nested_model_file
      generate_graphql_type
      generate_flex_component_controller_file
      generate_view_files
      add_route
      generate_flex_component_union_type
      add_to_flex_component_base_components
    end

    private

      def generate_nested_model_file
        generate "model #{file_name} #{@@attributes_flat}"
        inject_concerns
        inject_display_field_to_model
        inject_model_attachments
        inject_position_scope
      end

      def generate_flex_component_controller_file
        @attachments = @@attachments
        @polymorphic_name = polymorphic_name
        template "controllers/flex_component_scaffold_controller.rb", "app/controllers/#{options.namespace}/#{file_name.pluralize}_controller.rb"
      end

      def generate_view_files
        @form_attrs = set_form_attrs
        @attachments = @@attachments
        template "views/table_nested.html.#{options.template}", "app/views/#{options.namespace}/#{plural_file_name}/table.html.#{options.template}"
        template "views/_form_nested.html.#{options.template}", "app/views/#{options.namespace}/#{plural_file_name}/_form.html.#{options.template}"
        template "views/new_nested.html.#{options.template}", "app/views/#{options.namespace}/#{plural_file_name}/new.html.#{options.template}"
        template "views/edit_nested.html.#{options.template}", "app/views/#{options.namespace}/#{plural_file_name}/edit.html.#{options.template}"
      end

      def inject_concerns
        inject_into_file "app/models/#{file_name}.rb", after: /(ActiveRecord::Base|ApplicationRecord)\n/ do <<-RUBY
  include Fae::BaseModelConcern\n
  include Fae::BaseFlexComponentConcern\n
  has_flex_component name\n
RUBY
        end
      end

      def add_route
        inject_into_file "config/routes.rb", after: "namespace :#{options.namespace} do\n", force: true do <<-RUBY
      resources :#{plural_file_name}
  RUBY
        end
      end

      def generate_flex_component_union_type
        return unless uses_graphql
        file = "app/graphql/types/flex_component_union_type.rb"
        if ::File.exists?(Rails.root.join(file).to_s)
          inject_into_file "app/graphql/types/flex_component_union_type.rb", "Types::#{class_name}Type, ", after: 'possible_types('
        else
          template 'graphql/flex_component_union_type.rb', file
          inject_into_file "app/graphql/types/flex_component_union_type.rb", "Types::#{class_name}Type, ", after: 'possible_types('
        end
      end

      def add_to_flex_component_base_components
        inject_into_file "app/models/flex_component.rb", before: "# base components inject marker" do <<-RUBY
      "'#{class_name}'",\n\s\s\s\s\s\s\s
RUBY
        end
      end

  end
end
