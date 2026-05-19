module Fae
  class JoinModelGenerator < Rails::Generators::Base
    source_root ::File.expand_path('../templates', __FILE__)

    PASCAL_CASE_MODEL_NAME = /\A[A-Z][A-Za-z0-9]*(?:::[A-Z][A-Za-z0-9]*)*\z/

    argument :owner_model, type: :string
    argument :joined_model, type: :string

    def go
      validate_model_name!(owner_model_name, 'owner_model')
      validate_model_name!(joined_model_name, 'joined_model')
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
      demodulized_model_name(owner_model_name)
    end

    def joined_association_name
      demodulized_model_name(joined_model_name)
    end

    def owner_belongs_to_class_name_option
      belongs_to_class_name_option(owner_model_name)
    end

    def joined_belongs_to_class_name_option
      belongs_to_class_name_option(joined_model_name)
    end

    def owner_model_name
      owner_model.to_s.strip
    end

    def joined_model_name
      joined_model.to_s.strip
    end

    def demodulized_model_name(model_name)
      model_name.split('::').last.underscore
    end

    def belongs_to_class_name_option(model_name)
      return '' unless model_name.include?('::')

      ", class_name: '#{model_name}'"
    end

    def validate_model_name!(model_name, argument_name)
      return if model_name.match?(PASCAL_CASE_MODEL_NAME)

      raise Thor::Error,
            "#{argument_name} must be PascalCase (optionally namespaced), e.g. StaticPage or Fae::StaticPage"
    end
  end
end