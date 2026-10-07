require_relative 'base_generator'
module Fae
  class SingletonGenerator < Fae::BaseGenerator
    desc 'Creates a single-record model with an edit-only Fae section'
    source_root ::File.expand_path('../templates', __FILE__)

    def go
      generate_model
      inject_singleton_instance
      generate_graphql_type
      generate_singleton_controller_file
      generate_singleton_view_files
      add_singleton_route
      inject_singleton_nav_item
      inject_singleton_gql_query
    end

    private

    def draft_support?
      false
    end

    def inject_singleton_instance
      inject_into_file "app/models/#{file_name}.rb", after: "include Fae::BaseModelConcern\n" do
        <<~RUBY.indent(2)

          def self.instance
            first || new.tap { |item| item.save(validate: false) }
          end

        RUBY
      end
    end

    def generate_singleton_controller_file
      @attachments = @@attachments
      template "controllers/singleton_controller.rb", "app/controllers/#{options.namespace}/#{plural_file_name}_controller.rb"
    end

    def generate_singleton_view_files
      @form_attrs = set_form_attrs
      @association_names = @@association_names
      @attachments = @@attachments
      template "views/_form_singleton.html.#{options.template}", "app/views/#{options.namespace}/#{plural_file_name}/_form.html.#{options.template}"
      copy_file "views/edit.html.#{options.template}", "app/views/#{options.namespace}/#{plural_file_name}/edit.html.#{options.template}"
    end

    def add_singleton_route
      inject_into_file "config/routes.rb", after: "namespace :#{options.namespace} do\n", force: true do
        <<~RUBY.indent(4)
          resource :#{file_name}, only: [:edit, :update]
        RUBY
      end
    end

    def inject_singleton_nav_item
      line = "item('#{file_name.humanize.titlecase}', path: edit_#{options.namespace}_#{file_name}_path),\n\s\s\s\s\s\s\s\s"
      inject_into_file 'app/models/concerns/fae/navigation_concern.rb', line, before: '# scaffold inject marker'
    end

    def inject_singleton_gql_query
      return unless uses_graphql

      inject_into_file 'app/graphql/types/query_type.rb', after: "class QueryType < Types::BaseObject\n" do
        <<~RUBY.indent(4)

          field :#{file_name}, Types::#{class_name}Type, null: true do
            description "Returns the #{class_name} instance"
          end

          def #{file_name}
            #{class_name}.instance
          end
        RUBY
      end
    end

  end
end
