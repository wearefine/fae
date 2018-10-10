module Fae
  class StaticPage < ActiveRecord::Base
    include Fae::BaseModelConcern
    include Fae::StaticPageConcern

    validates :title, presence: true

    @current_locale = I18n.locale

    def self.instance
      setup_dynamic_methods
      row = includes(fae_fields.keys).references(fae_fields.keys).find_by_slug(@slug)
      row = create(title: @slug.titleize, slug: @slug) if row.blank?
      row
    end

    def self.fae_fields
      {}
    end

    def fae_display_field
      title
    end

    def as_json(options={})
      self.class.fae_fields.keys.map do |field|
        [field, field_json(field)]
      end.to_h
    end

  private

    def self.setup_dynamic_methods
      fae_fields.each do |name, value|
        type = value.is_a?(Hash) ? value[:type] : value
        languages = value.try(:[], :languages) || []
        process_field(languages, name, type, value)
      end
      @current_locale = I18n.locale
    end

    def self.process_field(languages, name, type, value)
      return methods_without_lang(name, type, value) if languages.empty?
      process_field_with_lang languages, name, type, value
    end

    def self.process_field_with_lang(languages, name, type, value)
      methods_with_lang(languages, name, type, value)

      if I18n.locale != @current_locale
        define_association(name, type, "#{name}_#{I18n.locale}")
      end
    end

    def self.methods_with_lang(languages, name, type, value)
      languages.each do |lang|
        # Save with suffix for form fields
        define_association("#{name}_#{lang}", type)
        if supports_validation(type, value)
          define_validations("#{name}_#{lang}", type, value[:validates])
        end
      end
    end

    def self.methods_without_lang(name, type, value)
      define_association(name, type)
      if supports_validation(type, value)
        define_validations(name, type, value[:validates])
      end
    end

    def self.define_association(name, type, locale_name = nil)
      locale_name ||= name
      send :has_one, name.to_sym, -> { where(attached_as: locale_name.to_s)}, as: poly_sym(type), class_name: type.to_s, dependent: :destroy
      send :accepts_nested_attributes_for, name, allow_destroy: true
      send :define_method, :"#{name}_content", -> { send(name.to_sym).try(:content) }
    end

    def self.define_validations(name, type, validations)
      unique_method_name = "is_#{self.name.underscore}_#{name.to_s}?".to_sym
      return if type.validators.any? do |val|
        val.options[:if] == unique_method_name
      end
      add_validations unique_method_name, type, validations, @slug
    end

    def self.add_validations(unique_method_name, type, validations, slug)
      validations[:if] = unique_method_name
      type.validates(:content, validations)
      type.send(:define_method, unique_method_name) do
        contentable.slug == slug && attached_as == name.to_s if contentable.present?
      end
    end

    def self.supports_validation(type, value)
      # validations are only supported on Fae::TextField and Fae::TextArea
      poly_sym(type) == :contentable && value.try(:[], :validates).present?
    end

    def self.poly_sym(assoc)
      case assoc.name
      when 'Fae::TextField', 'Fae::TextArea'
        return :contentable
      when 'Fae::Image'
        return :imageable
      when 'Fae::File'
        return :fileable
      end
    end

    def field_json(assoc)
      assoc_obj = self.send(assoc)
      case assoc_obj.class.name
      when 'Fae::TextField', 'Fae::TextArea'
        return assoc_obj.content
      when 'Fae::Image', 'Fae::File'
        assoc_json = assoc_obj.as_json
        assoc_json['asset'] = assoc_obj.asset.as_json
        return assoc_json
      else
        return assoc_obj.as_json
      end
    end
  end
end
