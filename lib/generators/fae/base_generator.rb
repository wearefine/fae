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
            @@attributes_flat << "#{arg.name}:#{arg.type}" + (arg.has_index? ? ":index" : "")
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
      inject_concern
      inject_display_field_to_model
      inject_model_attachments
      inject_position_scope
    end

    def generate_controller_file
      @attachments = @@attachments
      @inertia_form_fields = inertia_form_fields
      @inertia_unsupported_fields = inertia_unsupported_fields
      @inertia_index_columns = inertia_index_columns
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
      inject_into_file "config/routes.rb", after: "namespace :#{options.namespace} do\n", force: true do
        if static_page_generation?
          <<~RUBY.indent(4)
            resource :#{file_name}, only: [:edit, :update]
          RUBY
        else
          <<~RUBY.indent(4)
            resources :#{plural_file_name}
          RUBY
        end
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
      inject_into_file "app/models/#{file_name}.rb", after: /(ActiveRecord::Base|ApplicationRecord)\n/ do
        <<~RUBY.indent(2)
          include Fae::BaseModelConcern

        RUBY
      end
    end

    def inject_display_field_to_model
      if @@attribute_names.include? 'name'
        @@display_field = 'name'
      elsif @@attribute_names.include? 'title'
        @@display_field = 'title'
      end

      inject_into_file "app/models/#{file_name}.rb", after: "include Fae::BaseModelConcern\n" do
        <<~RUBY.indent(2)
          def fae_display_field
            #{@@display_field}
          end
        RUBY
      end
    end

    def inject_position_scope
      if @@has_position
        inject_into_file "app/models/#{file_name}.rb", after: "include Fae::BaseModelConcern\n" do
          <<~RUBY.indent(2)

            acts_as_list add_new_at: :top
            default_scope { order(:position) }

          RUBY
        end
      end
    end

    def inject_model_attachments
      return if @@attachments.blank?
      @@attachments.each do |attachment|
        if attachment.type == :image
          inject_into_file "app/models/#{file_name}.rb", after: "include Fae::BaseModelConcern\n" do
            <<~RUBY.indent(2)
              has_fae_image :#{attachment.name}

            RUBY
          end
        elsif attachment.type == :seo_set
          inject_into_file "app/models/#{file_name}.rb", after: "include Fae::BaseModelConcern\n" do
            <<~RUBY.indent(2)
              has_fae_seo_set :#{attachment.name}

            RUBY
          end
        elsif attachment.type == :cta
          inject_into_file "app/models/#{file_name}.rb", after: "include Fae::BaseModelConcern\n" do
            <<~RUBY.indent(2)
              has_fae_cta :#{attachment.name}

            RUBY
          end
        elsif attachment.type == :file
          inject_into_file "app/models/#{file_name}.rb", after: "include Fae::BaseModelConcern\n" do
            <<~RUBY.indent(2)
              has_fae_file :#{attachment.name}

            RUBY
          end
        end
      end
    end

    def inject_nav_item
      line = if static_page_generation?
               "item('#{file_name.humanize.titlecase}', path: edit_#{options.namespace}_#{file_name}_path),\n\s\s\s\s\s\s\s\s"
             else
               "item('#{plural_file_name.humanize.titlecase}', path: #{options.namespace}_#{plural_file_name}_path),\n\s\s\s\s\s\s\s\s"
             end
      inject_into_file 'app/models/concerns/fae/navigation_concern.rb', line, before: '# scaffold inject marker'
    end

    def static_page_generation?
      options.respond_to?(:static_page) && options.static_page
    end

    def inertia_form_fields
      attributes.filter_map do |arg|
        next if %w[position on_stage on_prod].include?(arg.name)

        if is_attachment(arg)
          supported_type = inertia_supported_attachment_type(arg.type)
          next if supported_type.blank?

          { name: arg.name.to_sym, type: supported_type }
        elsif is_association(arg)
          assoc_name = arg.name.to_s.gsub(/_id$/, '')
          field_name = arg.name.to_s.end_with?('_id') ? arg.name : "#{arg.name}_id"

          {
            name: field_name.to_sym,
            type: :select,
            collection: "#{assoc_name.classify}.for_fae_index"
          }
        else
          {
            name: arg.name.to_sym,
            type: inertia_type_for(arg.type)
          }
        end
      end
    end

    def inertia_unsupported_fields
      attributes.filter_map do |arg|
        next unless is_attachment(arg)
        next unless inertia_supported_attachment_type(arg.type).blank?

        { name: arg.name.to_sym, type: arg.type.to_sym }
      end
    end

    def inertia_index_columns
      primary_name = if @@display_field.present?
                       @@display_field
                     else
                       attributes.find do |arg|
                         !is_attachment(arg) &&
                           !is_association(arg) &&
                           !%w[position on_stage on_prod].include?(arg.name)
                       end&.name || 'id'
                     end

      columns = [{ key: primary_name.to_sym, label: primary_name.to_s.titleize }]
      columns << { key: :updated_at, label: 'Modified' }
      columns.concat(set_toggle_attrs.map { |attr| { key: attr.to_sym, label: attr.to_s.titleize } })
      columns
    end

    def inertia_type_for(type)
      case type.to_s
      when 'text'
        :textarea
      when 'boolean'
        :checkbox
      when 'date'
        :datepicker
      when 'datetime', 'timestamp'
        :'datetime-local'
      when 'integer', 'float', 'decimal'
        :number
      else
        :text
      end
    end

    def inertia_supported_attachment_type(type)
      case type.to_s
      when 'image'
        :image
      when 'file'
        :file
      else
        nil
      end
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
      model_name = file_name.titleize.gsub(' ', '')

      inject_into_file 'app/graphql/types/query_type.rb', after: "class QueryType < Types::BaseObject\n" do
        <<~RUBY.indent(4)

          field :#{file_name}_page, Types::#{model_name}PageType, null: true do
            description "Returns the #{model_name} Page instance"
          end

          def #{file_name}_page
            #{model_name}Page.instance
          end
        RUBY
      end
    end

    # This assumes your app has the Livable concern in it.
    # Which if you've started from our BE template, it should.
    def inject_livable
      return unless @@needs_livable

      inject_into_file "app/models/#{file_name}.rb", after: "include Fae::BaseModelConcern" do
        <<~RUBY.indent(2)

          include Livable

        RUBY
      end
    end

  end
end