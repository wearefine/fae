require_relative '../base_generator'

module Fae
  module Pages
    class ModelGenerator < Fae::BaseGenerator
      desc 'Creates model with dependancies for Fae Static Pages'
      source_root File.expand_path('../../templates', __FILE__)

      @@attributes = {}

      def set_globals
        establish_AR_connections
        if attributes.present?
          attributes.each do |attr|
            @@attributes[attr.name.to_sym] = convert_attr_type(attr.type)
          end
        end
      end

      def go
        generate_static_page_model
        generate_static_page_view
      end

      private

      def generate_static_page_model
        @attributes = @@attributes
        template "models/pages_model.rb", "app/models/#{file_name.singularize}_page.rb"
      end

      def generate_static_page_view
        @attributes = @@attributes
        template "views/static_page_form.html.#{options.template}", "app/views/#{options.namespace}/content_blocks/#{file_name.singularize}.html.#{options.template}"
      end

      def establish_AR_connections
        Fae::TextField.connection
        Fae::TextArea.connection
        Fae::Image.connection
        Fae::File.connection
      end

      def convert_attr_type(type)
        case type.to_s
        when "string"
          "Fae::TextField"
        when "text"
          "Fae::TextArea"
        when "image"
          "Fae::Image"
        when "file"
          "Fae::File"
        else
          type
        end
      end
    end
  end
end
