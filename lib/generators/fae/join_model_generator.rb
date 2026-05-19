module Fae
  class JoinModelGenerator < Rails::Generators::Base
    source_root ::File.expand_path('../templates', __FILE__)

    argument :owner_model, type: :string
    argument :joined_model, type: :string

    def go
      generate_join_model
      generate_join_model_file
    end

    private

    def generate_join_model
      generate "model #{join_model_file_name} #{owner_reference_attribute} #{joined_reference_attribute} position:integer:index"
    end

    def generate_join_model_file
      template "models/join_model.rb", "app/models/#{join_model_file_name}.rb", force: true
    end

    def join_model_file_name
      "#{owner_association_name}_#{joined_association_name}"
    end

    def join_model_class_name
      "#{owner_association_name.classify}#{joined_association_name.classify}"
    end

    def owner_reference_attribute
      "#{owner_association_name}:references:index"
    end

    def joined_reference_attribute
      "#{joined_association_name}:references:index"
    end

    def owner_association_name
      normalize_model_name(owner_model)
    end

    def joined_association_name
      normalize_model_name(joined_model)
    end

    def normalize_model_name(model_name)
      model_name.to_s.strip.split('::').last.underscore
    end
  end
end