require_relative 'base_generator'
module Fae
  class FlexComponentGenerator < Fae::BaseGenerator
    source_root ::File.expand_path('../templates', __FILE__)

    def go
      generate_nested_model_file
      generate_graphql_type
      generate_flex_component_controller_file
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
        @inertia_form_fields = inertia_form_fields
        @inertia_unsupported_fields = inertia_unsupported_fields
        template "controllers/flex_component_scaffold_controller.rb", "app/controllers/#{options.namespace}/#{file_name.pluralize}_controller.rb"
      end

      def inject_concerns
        inject_into_file "app/models/#{file_name}.rb", after: /(ActiveRecord::Base|ApplicationRecord)\n/ do
          <<~RUBY.indent(2)
            include Fae::BaseModelConcern
            include Fae::BaseFlexComponentConcern

          RUBY
        end
      end

      def add_route
        inject_into_file "config/routes.rb", after: "namespace :#{options.namespace} do\n", force: true do
          <<~RUBY.indent(4)
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
        inject_into_file "app/models/concerns/fae/flex_component_concern.rb", after: "def base_components\n\s\s\s\s\s\s\s\s[" do
          "'#{class_name}',\s"
        end
      end

  end
end
