require_relative 'base_generator'
module Fae
  class NestedScaffoldGenerator < Fae::BaseGenerator
    source_root File.expand_path('../templates', __FILE__)
    class_option :parent_model, type: :string, desc: 'Sets the parent model this scaffold belongs_to.'

    def go
      generate_nested_model_file
      # generate_nested_controller_file
      # generate_view_files
      # add_route
    end


    private

      def generate_nested_model_file
        add_association_into_model
        generate "model #{file_name} #{@@attributes_flat}"
        inject_touch_option_into_model
        inject_belongs_to_into_model_spec
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

      def add_association_into_model
        @@attributes_flat << " #{options.parent_model.underscore}:references" if options[:parent_model].present?
        @@attributes_flat = @@attributes_flat.split(' ').uniq.join(' ')
      end

      def inject_touch_option_into_model
        if options.parent_model.present?
          inject_into_file "app/models/#{file_name}.rb", after: "belongs_to :#{options.parent_model.underscore}" do <<-RUBY
, touch: true
RUBY
          end
        end
      end

      def inject_belongs_to_into_model_spec
        if options.parent_model.present?
          gsub_file "spec/models/#{file_name}_spec.rb", 'pending "add some examples to (or delete) #{__FILE__}"', "it { is_expected.to belong_to(:#{options.parent_model.underscore}).touch(:true) }"
        end
      end

  end
end