module Fae
  class BaseGenerator < Rails::Generators::NamedBase
    source_root ::File.expand_path('../templates', __FILE__)
    argument :attributes, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"
    class_option :namespace, type: :string, default: 'admin', desc: 'Sets the namespace of the generator'
    class_option :template, type: :string, default: 'slim', desc: 'Sets the template engine of the generator'
    class_option :polymorphic, type: :boolean, default: false, desc: 'Makes the model and scaffolding polymorphic. parent-model is ignored if passed.'
    Rails::Generators::GeneratedAttribute::DEFAULT_TYPES += ['image', 'file', 'seo_set', 'cta']

    @@attributes_flat = []
    @@attribute_names = []
    @@association_names = []
    @@attachments = []
    @@graphql_attributes = []
    @@has_position = false
    @@display_field = ''
    @@needs_livable = false

    def check_template_support
      supported_templates = ['slim']
      raise "Fae::UnsupportedTemplate: the template engine you defined isn't supported" unless supported_templates.include?(options.template)
    end

    def set_globals
      if attributes.present?
        attributes.each do |arg|
          # prevent these from being in attributes_flat or attribute_names as they are not real model generator field options
          if is_attachment(arg)
            @@attachments << arg
          else
            @@attributes_flat << format_attribute(arg)
          end

          if options.polymorphic
            @@attributes_flat << "#{polymorphic_name}:references{polymorphic}"
          end

          if is_association(arg)
            @@association_names << arg.name.gsub(/_id$/, '')
          elsif !is_attachment(arg)
            @@attribute_names << arg.name
          end
          @@has_position = true if arg.name === 'position'
          @@needs_livable = true if arg.name == 'on_prod'

          @@graphql_attributes << graphql_object(arg)
        end

        @@association_names.uniq!
        @@attribute_names.uniq!
        @@attachments.uniq!
        @@graphql_attributes.uniq!
      end

      # Always add an indexed draft boolean column for scaffold-generated objects
      @@attributes_flat << "draft:boolean:index"

      @@attributes_flat = @@attributes_flat.uniq.join(' ')
    end

  private

    ## Generator Methods

    def generate_model
      generate "model #{file_name} #{@@attributes_flat}"
      apply_special_defaults_to_latest_migration(file_name)
      inject_concern
      inject_display_field_to_model
      inject_model_attachments
      inject_field_failoverable
      inject_position_scope
    end

    def generate_controller_file
      @attachments = @@attachments
      template "controllers/scaffold_controller.rb", "app/controllers/#{options.namespace}/#{file_name.pluralize}_controller.rb"
    end

    def generate_view_files
      @toggle_attrs = set_toggle_attrs
      @form_attrs = set_form_attrs
      @association_names = @@association_names
      @attachments = @@attachments
      @has_position = @@has_position
      @display_field = @@display_field
      @polymorphic_name = polymorphic_name
      template "views/index.html.#{options.template}", "app/views/#{options.namespace}/#{plural_file_name}/index.html.#{options.template}"
      template "views/_form.html.#{options.template}", "app/views/#{options.namespace}/#{plural_file_name}/_form.html.#{options.template}"
      copy_file "views/new.html.#{options.template}", "app/views/#{options.namespace}/#{plural_file_name}/new.html.#{options.template}"
      copy_file "views/edit.html.#{options.template}", "app/views/#{options.namespace}/#{plural_file_name}/edit.html.#{options.template}"
    end

    def add_route
      inject_into_file "config/routes.rb", after: "namespace :#{options.namespace} do\n", force: true do <<-RUBY
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
      inject_into_file "app/models/#{file_name}.rb", after: /(ActiveRecord::Base|ApplicationRecord)\n/ do <<-RUBY
  include Fae::BaseModelConcern\n
RUBY
      end
    end

    def inject_display_field_to_model
      if @@attribute_names.include? 'name'
        @@display_field = 'name'
      elsif @@attribute_names.include? 'title'
        @@display_field = 'title'
      end

      inject_into_file "app/models/#{file_name}.rb", after: "include Fae::BaseModelConcern\n" do <<-RUBY
  def fae_display_field
    #{@@display_field}
  end
RUBY
      end

    end

    def inject_position_scope
      if @@has_position
        inject_into_file "app/models/#{file_name}.rb", after: "include Fae::BaseModelConcern\n" do <<-RUBY
\n  acts_as_list add_new_at: :top
  default_scope { order(:position) }\n
RUBY
        end
      end
    end

    def inject_model_attachments
      return if @@attachments.blank?
      @@attachments.each do |attachment|
        if attachment.type == :image
          inject_into_file "app/models/#{file_name}.rb", after: "include Fae::BaseModelConcern\n" do
            <<-RUBY
  has_fae_image :#{attachment.name}\n
RUBY
          end
        elsif attachment.type == :seo_set
            inject_into_file "app/models/#{file_name}.rb", after: "include Fae::BaseModelConcern\n" do
              <<-RUBY
    has_fae_seo_set :#{attachment.name}\n
  RUBY
            end
          elsif attachment.type == :cta
            inject_into_file "app/models/#{file_name}.rb", after: "include Fae::BaseModelConcern\n" do
              <<-RUBY
    has_fae_cta :#{attachment.name}\n
  RUBY
            end
        elsif attachment.type == :file
          inject_into_file "app/models/#{file_name}.rb", after: "include Fae::BaseModelConcern\n" do
            <<-RUBY
  has_fae_file :#{attachment.name}\n
RUBY
          end
        end
      end
    end

    def inject_field_failoverable
      return unless needs_field_failoverable?

      inject_into_file "app/models/#{file_name}.rb", after: "include Fae::BaseModelConcern\n" do
        <<-RUBY
  include FieldFailoverable

  def failover_seo_title
    #{failover_seo_title_body}
  end

RUBY
      end
    end

    def inject_nav_item
      line = "item('#{plural_file_name.humanize.titlecase}', path: #{options.namespace}_#{plural_file_name}_path),\n\s\s\s\s\s\s\s\s"
      inject_into_file 'app/models/concerns/fae/navigation_concern.rb', line, before: '# scaffold inject marker'
    end

    def graphql_object(arg)
      if is_association(arg)
        assoc_name = arg.name.gsub(/_id$/, '')
        assoc_type = "Types::#{assoc_name.classify}Type"
        { attr: assoc_name.to_sym, type: assoc_type }
      else
        { attr: arg.name.to_sym, type: graphql_type(arg.type) }
      end
    end

    def graphql_type(type)
      case type.to_s
      when 'integer'
        'Integer'
      when 'boolean'
        'Boolean'
      when 'image'
        'Types::FaeImageType'
      when 'file'
        'Types::FaeFileType'
      when 'seo_set'
        'Types::FaeSeoSetType'
      when 'cta'
        'Types::FaeCtaType'
      else
        'String'
      end
    end

    def generate_graphql_type
      return unless uses_graphql
      @graphql_attributes = @@graphql_attributes
      template "graphql/graphql_type.rb", "app/graphql/types/#{file_name}_type.rb"
      inject_base_seo_fields_to_graphql_type
    end

    def uses_graphql
      defined?(GraphQL)
    end

    def is_association(arg)
      arg.name.end_with?('_id') || arg.type.to_s == 'references'
    end

    def is_attachment(arg)
      [:image, :file, :seo_set, :cta].include?(arg.type)
    end

    def needs_field_failoverable?
      @@attribute_names.include?('seo_title') && field_failoverable_available?
    end

    def field_failoverable_available?
      ::File.exist?(Rails.root.join('app/models/concerns/field_failoverable.rb'))
    end

    def failover_seo_title_body
      if @@attribute_names.include?('name')
        'name'
      elsif @@attribute_names.include?('title')
        'title'
      else
        '#TODO'
      end
    end

    def inject_base_seo_fields_to_graphql_type
      return unless needs_base_seo_fields_in_graphql?

      graphql_type_file = "app/graphql/types/#{file_name}_type.rb"
      return unless ::File.exist?(Rails.root.join(graphql_type_file))
      return if ::File.read(Rails.root.join(graphql_type_file)).include?('implements Types::BaseSeoFields')

      inject_into_file graphql_type_file, after: "class Types::#{class_name}Type < Types::BaseObject\n" do
        <<-RUBY
  implements Types::BaseSeoFields

RUBY
      end
    end

    def needs_base_seo_fields_in_graphql?
      @@attribute_names.include?('seo_title') && base_seo_fields_available?
    end

    def base_seo_fields_available?
      ::File.exist?(Rails.root.join('app/graphql/types/base_seo_fields.rb'))
    end

    def format_attribute(arg)
      type = arg.type.to_s

      if arg.name == 'on_stage' && type == 'boolean'
        return 'on_stage:boolean:index'
      end

      if arg.name == 'on_prod' && type == 'boolean'
        return 'on_prod:boolean:index'
      end

      if arg.name == 'position' && type == 'integer'
        return 'position:integer:index'
      end

      if arg.name == 'slug' && type == 'string'
        return 'slug:string:index'
      end

      if arg.name == 'static_page_id' && type == 'integer'
        return 'static_page_id:integer:index'
      end

      "#{arg.name}:#{arg.type}" + (arg.has_index? ? ':index' : '')
    end

    def apply_special_defaults_to_latest_migration(model_name)
      migration_pattern = Rails.root.join('db/migrate', "*_create_#{model_name.pluralize}.rb").to_s
      migration_file = Dir.glob(migration_pattern).max
      return unless migration_file && ::File.exist?(migration_file)

      gsub_file migration_file, /^(\s*)t\.boolean :on_stage(?:,.*)?$/, '\1t.boolean :on_stage, default: true'
      gsub_file migration_file, /^(\s*)t\.boolean :on_prod(?:,.*)?$/, '\1t.boolean :on_prod, default: false'
    end

    def polymorphic_name
      "#{file_name.underscore}able"
    end

    def polymorphic_name
      "#{file_name.underscore}able"
    end

    ####################################################################
    # FINE specific methods
    ####################################################################

    def inject_static_page_gql_query
      # return unless uses_graphql
      inject_into_file 'app/graphql/types/query_type.rb', after: "class QueryType < Types::BaseObject\n" do
        <<-RUBY

    field :#{file_name}_page, Types::#{file_name.titleize.gsub(' ','')}PageType, null: true do
      description "Returns the #{file_name.titleize.gsub(' ','')} Page instance"
    end

    def #{file_name}_page
      #{file_name.titleize.gsub(' ','')}Page.instance
    end
RUBY
      end
    end

    # This assumes your app has the Livable concern in it.
    # Which if you've started from our BE template, it should.
    def inject_livable
      if @@needs_livable
        inject_into_file "app/models/#{file_name}.rb", after: "include Fae::BaseModelConcern" do <<-RUBY

  include Livable\n
RUBY
        end

      end
    end

  end
end