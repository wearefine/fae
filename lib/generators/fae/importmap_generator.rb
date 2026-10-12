module Fae
  class ImportmapGenerator < Rails::Generators::Base
    source_root ::File.expand_path('../templates', __FILE__)
    desc 'Adds the files a host app needs to extend the Fae admin with its own ES modules and Stimulus controllers'

    def add_importmap_config
      copy_file 'importmap/fae_importmap.rb', 'config/fae_importmap.rb'
    end

    def add_entry_point
      copy_file 'importmap/fae_custom.js', 'app/javascript/fae_custom.js'
      create_file 'app/javascript/fae_custom/controllers/.keep'
    end

    def link_assets
      manifest = ::File.join(destination_root, 'app/assets/config/manifest.js')
      return unless ::File.exist?(manifest)

      content = ::File.read(manifest)
      return if content.include?('link fae_custom.js')

      append_to_file manifest, "#{"\n" unless content.end_with?("\n") || content.empty?}" + <<~JS
        //= link fae_custom.js
        //= link_tree ../../javascript/fae_custom .js
      JS
    end

  end
end
