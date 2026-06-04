require_relative 'base_generator'
module Fae
  class PageGenerator < Fae::BaseGenerator
    desc 'Creates model with dependancies for Fae Static Pages'
    source_root ::File.expand_path('../templates', __FILE__)

    @@attributes = {}

    def set_globals
      if attributes.present?
        attributes.each do |attr|
          @@attributes[attr.name.to_sym] = convert_attr_type(attr.type)
          @@graphql_attributes << graphql_object(attr)
        end
      end
    end

    def go
      generate_static_page_controller
      generate_static_page_model
      generate_graphql_type
      generate_static_page_view
      inject_static_page_gql_query
    end

    private

    def generate_static_page_controller
      file = "app/controllers/#{options.namespace}/content_blocks_controller.rb"
      if ::File.exist?(Rails.root.join(file).to_s)
        inject_into_file "app/controllers/#{options.namespace}/content_blocks_controller.rb", ", #{class_name}Page", before: ']'
      else
        template 'controllers/static_pages_controller.rb', file
      end
    end

    def generate_static_page_model
      @attributes = @@attributes
      template "models/pages_model.rb", "app/models/#{file_name}_page.rb"
      inject_field_failoverable_for_page
    end

    def generate_graphql_type
      return unless uses_graphql
      @graphql_attributes = @@graphql_attributes
      template "graphql/graphql_page_type.rb", "app/graphql/types/#{file_name}_page_type.rb"
      inject_base_seo_fields_to_page_graphql_type
    end

    def generate_static_page_view
      @attributes = @@attributes
      template "views/static_page_form.html.#{options.template}", "app/views/#{options.namespace}/content_blocks/#{file_name}.html.#{options.template}"
    end

    def connect_object object
      object.constantize.connection
      object
    end

    def convert_attr_type(type)
      case type.to_s
      when "string"
        connect_object "Fae::TextField"
      when "text"
        connect_object "Fae::TextArea"
      when "image"
        connect_object "Fae::Image"
      when "file"
        connect_object "Fae::File"
      when "cta"
        connect_object "Fae::Cta"
      else
        type
      end
    end

    def inject_field_failoverable_for_page
      return unless needs_field_failoverable_for_page?

      inject_into_file "app/models/#{file_name}_page.rb", after: "class #{class_name}Page < Fae::StaticPage\n" do
        <<-RUBY

  include FieldFailoverable

  def failover_seo_title
    #{page_failover_seo_title_body}
  end
RUBY
      end
    end

    def needs_field_failoverable_for_page?
      page_has_field?(:seo_title) && field_failoverable_available?
    end

    def page_has_field?(field_name)
      @@attributes.key?(field_name.to_sym)
    end

    def page_failover_seo_title_body
      if page_has_field?(:name)
        'name'
      elsif page_has_field?(:title)
        'title'
      else
        '#TODO'
      end
    end

    def inject_base_seo_fields_to_page_graphql_type
      return unless needs_base_seo_fields_in_page_graphql?

      page_graphql_type_file = "app/graphql/types/#{file_name}_page_type.rb"
      return unless ::File.exist?(Rails.root.join(page_graphql_type_file))
      return if ::File.read(Rails.root.join(page_graphql_type_file)).include?('implements Types::BaseSeoFields')

      inject_into_file page_graphql_type_file, after: "class Types::#{class_name}PageType < Types::BaseObject\n" do
        <<-RUBY
  implements Types::BaseSeoFields

RUBY
      end
    end

    def needs_base_seo_fields_in_page_graphql?
      page_has_field?(:seo_title) && base_seo_fields_available?
    end
  end
end
