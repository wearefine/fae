module Fae
  class BaseGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)
    argument :attributes, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"
    class_option :namespace, type: :string, default: 'admin', desc: 'Sets the namespace of the generator'
    class_option :template, type: :string, default: 'slim', desc: 'Sets the template engine of the generator'

    @@attributes_flat = ''
    @@attribute_names = []
    @@association_names = []
    @@has_position = false
    @@display_field = ''

    def check_template_support
      supported_templates = ['slim']
      raise "Fae::UnsupportedTemplate: the template engine you defined isn't supported" unless supported_templates.include?(options.template)
    end

    def set_globals
      if attributes.present?
        attributes.each do |arg|
          @@attributes_flat << "#{arg.name}:#{arg.type} "
          if arg.name['_id'] || arg.type.to_s == 'references'
            @@association_names << arg.name.gsub('_id', '')
          else
            @@attribute_names << arg.name
          end
          @@has_position = true if arg.name === 'position'
        end
      end
    end

  private

    ## Generator Methods

    def generate_model
      generate "model #{file_name} #{@@attributes_flat}"
      inject_concern
      inject_display_field
      inject_position_scope
    end

    def generate_controller_file
      template "controllers/scaffold_controller.rb", "app/controllers/#{options.namespace}/#{file_name.pluralize}_controller.rb"
    end

    def generate_view_files
      @toggle_attrs = set_toggle_attrs
      @form_attrs = set_form_attrs
      @association_names = @@association_names
      @has_position = @@has_position
      @display_field = @@display_field
      template "views/index.html.#{options.template}", "app/views/#{options.namespace}/#{plural_file_name}/index.html.#{options.template}"
      template "views/_form.html.#{options.template}", "app/views/#{options.namespace}/#{plural_file_name}/_form.html.#{options.template}"
      copy_file "views/new.html.#{options.template}", "app/views/#{options.namespace}/#{plural_file_name}/new.html.#{options.template}"
      copy_file "views/edit.html.#{options.template}", "app/views/#{options.namespace}/#{plural_file_name}/edit.html.#{options.template}"
    end

    def add_route
      inject_into_file "config/routes.rb", after: "namespace :#{options.namespace} do\n" do <<-RUBY
    resources :#{plural_file_name}
RUBY
      end
    end

    ## Helper Methods

    def set_toggle_attrs
      ['active', 'on_stage', 'on_prod'] & @@attribute_names
    end

    def set_form_attrs
      rejected_attrs = ['position', 'on_stage', 'on_prod']
      @@attribute_names.delete_if { |i| rejected_attrs.include?(i)}
    end

    def inject_concern
      inject_into_file "app/models/#{file_name}.rb", after: "ActiveRecord::Base\n" do <<-RUBY
  include Fae::Concerns::Models::Base\n
RUBY
      end
    end

    def inject_display_field
      if @@attribute_names.include? 'name'
        @@display_field = 'name'
      elsif @@attribute_names.include? 'title'
        @@display_field = 'title'
      end

      inject_into_file "app/models/#{file_name}.rb", after: "include Fae::Concerns::Models::Base\n" do <<-RUBY
\n  def fae_display_field
    #{@@display_field}
  end
RUBY
      end

    end

    def inject_position_scope
      if @@has_position
        inject_into_file "app/models/#{file_name}.rb", after: "include Fae::Concerns::Models::Base\n" do <<-RUBY
\n  acts_as_list add_new_at: :top
  default_scope { order(:position) }
RUBY
        end
      end
    end

  end
end