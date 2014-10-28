module Fae
  class ScaffoldGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)
    argument :attributes, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"

    @@live_flags = ['active','live','on_stage','on_prod']
    @@attributes_flat = ''
    @@attribute_names = ''
    @@has_position = false

    def set_globals
      if attributes.present?
        attributes.each do |arg|
          @@attributes_flat << "#{arg.name}:#{arg.type} "
          @@attribute_names << arg.name
          @@has_position = true if arg.name === 'position'
        end
      end
    end

    def generate_model
      if behavior == :revoke
        destroy = `rails destroy model #{file_name}`
        puts destroy
      else
        generate "model #{file_name} #{@@attributes_flat} --test-framework=false"
        inject_position_scope
        inject_display_field
      end
    end

    private

    def inject_display_field
      display_name = ''
      if @@attribute_names.include? 'name'
        display_name = 'name'
      elsif @@attribute_names.include? 'title'
        display_name = 'title'
      end

      if display_name.present?
        inject_into_file "app/models/#{file_name}.rb", after: "ActiveRecord::Base\n" do <<-RUBY
\n  def display_field
    #{display_name}
  end\n
RUBY
        end
      end
    end

    def inject_position_scope
      if @@has_position
        inject_into_file "app/models/#{file_name}.rb", after: "ActiveRecord::Base\n" do <<-RUBY
\n  acts_as_list add_new_at: :top
  default_scope order: :position\n
RUBY
        end
      end
    end

  end
end