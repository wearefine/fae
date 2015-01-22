require_relative 'base_generator'
module Fae
  class NestedScaffoldGenerator < Fae::BaseGenerator
    source_root File.expand_path('../templates', __FILE__)
    class_option :parent_model, type: :string, desc: 'Sets the parent model this scaffold belongs_to.'

    def go
      generate_nested_model_file
      generate_nested_controller_file
      generate_view_files
    end


    private

      def generate_nested_model_file
        generate "model #{file_name} #{@@attributes_flat}"
        inject_touch_option_into_model
      end

      def generate_nested_controller_file
        template "controllers/nested_scaffold_controller.rb", "app/controllers/#{options.namespace}/#{file_name.pluralize}_controller.rb"
      end

      def generate_view_files
        @form_attrs = set_form_attrs
        template "views/table_nested.html.#{options.template}", "app/views/#{options.namespace}/#{plural_file_name}/table.html.#{options.template}"
        template "views/_form_nested.html.#{options.template}", "app/views/#{options.namespace}/#{plural_file_name}/_form.html.#{options.template}"
        template "views/new_nested.html.#{options.template}", "app/views/#{options.namespace}/#{plural_file_name}/new.html.#{options.template}"
        template "views/edit_nested.html.#{options.template}", "app/views/#{options.namespace}/#{plural_file_name}/edit.html.#{options.template}"
      end

      def inject_touch_option_into_model
        if options.parent_model.present?
          inject_into_file "app/models/#{file_name}.rb", after: "belongs_to :#{options.parent_model.underscore}" do <<-RUBY
, touch: true
RUBY
          end
        end
      end

  end
end