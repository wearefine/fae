require_relative 'base_generator'

module Fae
  class PageGenerator < Fae::BaseGenerator
    desc 'Creates model with dependancies for Fae Static Pages'
    source_root File.expand_path('../templates', __FILE__)

    @@attributes = {}

    def set_globals
      if attributes.present?
        attributes.each do |attr|
          @@attributes[attr.name.to_sym] = convert_attr_type(attr.type)
        end
      end
    end

    def go
      generate_static_page_controller
      generate_static_page_model
      generate_static_page_view
      inject_into_file "app/controllers/#{options.namespace}/content_blocks_controller.rb", "#{class_name}Page, ", before: ']'
    end

    private

    def generate_static_page_controller
      template 'controllers/static_pages_controller.rb', "app/controllers/#{options.namespace}/content_blocks_controller.rb"
    end

    def generate_static_page_model
      @attributes = @@attributes
      template "models/pages_model.rb", "app/models/#{file_name.singularize}_page.rb"
    end

    def generate_static_page_view
      @attributes = @@attributes
      template "views/static_page_form.html.#{options.template}", "app/views/#{options.namespace}/content_blocks/#{file_name.singularize}.html.#{options.template}"
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
      else
        type
      end
    end
  end
end
