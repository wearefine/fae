module Fae
  module Pages
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../../templates', __FILE__)
      class_option :namespace, type: :string, default: 'admin', desc: 'Sets the namespace of the generator'

      def install
        generate_controller_file
      end

    private

      def generate_controller_file
        template 'controllers/static_pages_controller.rb', "app/controllers/#{options.namespace}/content_blocks_controller.rb"
      end
    end
  end
end
