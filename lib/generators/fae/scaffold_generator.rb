module Fae
  class ScaffoldGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)
    argument :attributes, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"
    class_option :namespace, type: :string, default: 'admin', desc: 'Sets the namespace of the generator'

    @@attributes_flat = ''
    @@attribute_names = []
    @@has_position = false
    @@display_field = ''

    def set_globals
      if attributes.present?
        attributes.each do |arg|
          @@attributes_flat << "#{arg.name}:#{arg.type} "
          @@attribute_names << arg.name
          @@has_position = true if arg.name === 'position'
        end
      end
    end

    def generate_model
      if behavior == :revoke
        destroy = `rails destroy model #{file_name}`
        puts destroy
      else
        generate "model #{file_name} #{@@attributes_flat} --test-framework=false"
        inject_position_scope
        inject_display_field
      end
    end

    def generate_controller_file
      template "controllers/scaffold_controller.rb", "app/controllers/#{options.namespace}/#{file_name.pluralize}_controller.rb"
    end

    def generate_view_files
      @toggle_attrs = set_toggle_attrs
      @form_attrs = set_form_attrs
      @has_position = @@has_position
      @display_field = @@display_field
      # @attrs_for_form = set_attrs_for_form
      template "views/index.html.slim", "app/views/admin/#{plural_file_name}/index.html.slim"
      template "views/_form.html.slim", "app/views/admin/#{plural_file_name}/_form.html.slim"
      copy_file "views/new.html.slim", "app/views/admin/#{plural_file_name}/new.html.slim"
      copy_file "views/edit.html.slim", "app/views/admin/#{plural_file_name}/edit.html.slim"
    end

  private

    def set_toggle_attrs
      ['active', 'on_stage', 'on_prod'] & @@attribute_names
    end

    def set_form_attrs
      rejected_attrs = ['position', 'on_stage', 'on_prod']
      @@attribute_names.delete_if { |i| rejected_attrs.include?(i)}
    end

    def inject_display_field
      if @@attribute_names.include? 'name'
        @@display_field = 'name'
      elsif @@attribute_names.include? 'title'
        @@display_field = 'title'
      end

      if @@display_field.present?
        inject_into_file "app/models/#{file_name}.rb", after: "ActiveRecord::Base\n" do <<-RUBY
\n  def display_field
    #{@@display_field}
  end\n
RUBY
        end
      end
    end

    def inject_position_scope
      if @@has_position
        inject_into_file "app/models/#{file_name}.rb", after: "ActiveRecord::Base\n" do <<-RUBY
\n  acts_as_list add_new_at: :top
  default_scope order: :position\n
RUBY
        end
      end
    end

  end
end