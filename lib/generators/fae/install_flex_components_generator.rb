module Fae
  class InstallFlexComponentsGenerator < Rails::Generators::Base
    source_root ::File.expand_path('../templates', __FILE__)
    class_option :namespace, type: :string, default: 'admin', desc: 'Sets the namespace of the generator'
    class_option :template, type: :string, default: 'slim', desc: 'Sets the template engine of the generator'

    def install
      add_route
      add_files
      rake 'fae:install:migrations'
      rake 'db:migrate'
    end

  private

    def add_route
      inject_into_file "config/routes.rb", after: "namespace :#{options.namespace} do\n", force: true do <<-RUBY
    resources :flex_components
  RUBY
      end
    end

    def add_files
      template 'controllers/flex_components_controller.rb', "app/controllers/#{options.namespace}/flex_components_controller.rb"

      template 'models/concerns/flex_componentable_concern.rb', 'app/models/concerns/flex_componentable_concern.rb'
      template 'models/concerns/flex_component_concern.rb', 'app/models/concerns/fae/flex_component_concern.rb'

      template "views/flex_components/new.html.#{options.template}", "app/views/#{options.namespace}/flex_components/new.html.#{options.template}"
      template "views/flex_components/edit.html.#{options.template}", "app/views/#{options.namespace}/flex_components/edit.html.#{options.template}"
      template "views/flex_components/_form.html.#{options.template}", "app/views/#{options.namespace}/flex_components/_form.html.#{options.template}"

      if uses_graphql
        template 'graphql/flex_component_type.rb', 'app/graphql/types/flex_component_type.rb'
        template 'graphql/flex_component_union_type.rb', 'app/graphql/types/flex_component_union_type.rb'
      end
    end

    def uses_graphql
      defined?(GraphQL)
    end

  end
end