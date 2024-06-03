require_relative 'base_generator'
module Fae
  class NestedScaffoldGenerator < Fae::BaseGenerator
    source_root ::File.expand_path('../templates', __FILE__)
    class_option :parent_model, type: :string, desc: 'Sets the parent model this scaffold belongs_to.'

    def go
      generate_nested_model_file
      generate_graphql_type
      generate_nested_controller_file
      generate_view_files
      add_route
      inject_livable
      generate_flex_component_union_type if options.flex_component
    end

    private

      def generate_nested_model_file
        generate "model #{file_name} #{@@attributes_flat}"
        inject_concern
        inject_display_field_to_model
        inject_model_attachments
        inject_position_scope
        inject_parent_info if options.parent_model.present?
        inject_polymorphic_info if options.polymorphic
      end

      def generate_nested_controller_file
        @attachments = @@attachments
        @polymorphic_name = polymorphic_name
        template "controllers/nested_scaffold_controller.rb", "app/controllers/#{options.namespace}/#{file_name.pluralize}_controller.rb"
      end

      def generate_view_files
        @form_attrs = set_form_attrs
        @attachments = @@attachments
        template "views/table_nested.html.#{options.template}", "app/views/#{options.namespace}/#{plural_file_name}/table.html.#{options.template}"
        template "views/_form_nested.html.#{options.template}", "app/views/#{options.namespace}/#{plural_file_name}/_form.html.#{options.template}"
        template "views/new_nested.html.#{options.template}", "app/views/#{options.namespace}/#{plural_file_name}/new.html.#{options.template}"
        template "views/edit_nested.html.#{options.template}", "app/views/#{options.namespace}/#{plural_file_name}/edit.html.#{options.template}"
      end

      def inject_parent_info
        inject_into_file "app/models/#{file_name}.rb", after: "BaseModelConcern\n" do <<-RUBY
        \n  belongs_to :#{options.parent_model.underscore}, touch: true
          def fae_nested_parent
            :#{options.parent_model.underscore}
          end
        RUBY
        end
      end

      def inject_polymorphic_info
        inject_into_file "app/models/#{file_name}.rb", after: "BaseModelConcern\n" do <<-RUBY

  def fae_nested_parent
    :#{polymorphic_name}
  end

RUBY
        end
      end

  end
end
