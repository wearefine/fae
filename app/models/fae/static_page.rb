module Fae
  class StaticPage < ActiveRecord::Base

    include Fae::BaseModelConcern
    include Fae::StaticPageConcern

    validates :title, presence: true

    @singleton_is_setup = false

    def self.instance
      setup_dynamic_singleton
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

  def self.fae_translate(*attributes)
    attributes.each do |attribute|
      define_method attribute.to_s do
        if self.try("#{attribute}_#{I18n.locale}").content.present?
          self.send "#{attribute}_#{I18n.locale}"
        else
          self.send "#{attribute}_en"
        end
      end

      define_singleton_method "find_by_#{attribute}" do |val|
        if self.has_attribute?("#{attribute}_#{I18n.locale}")
          self.send("find_by_#{attribute}_#{I18n.locale}", val)
        else
          self.send("find_by_#{attribute}_en", val)
        end
      end
    end
  end

    def self.setup_dynamic_singleton
      return if @singleton_is_setup

      fae_fields.each do |name, value|
        type = value.is_a?(Hash) ? value[:type] : value
        languages = value.try(:[], :languages)

        if languages.present?
          languages.each do |lang|
            # Save with suffix for form fields
            define_association("#{name}_#{lang}", type)
            define_validations("#{name}_#{lang}", type, value[:validates]) if supports_validation(type, value)
          end
          # Save with lookup to have default language return in front-end use (don't need to worry about validations here)
          default_language = Rails.application.config.i18n.default_locale || languages.first
          define_association(name, type, "#{name}_#{default_language}")
        else
          # Normal content_blocks
          define_association(name, type)
          define_validations(name, type, value[:validates]) if supports_validation(type, value)
        end
      end

      @singleton_is_setup = true
    end

    def self.define_association(name, type, locale_name = nil)
      locale_name ||= name

      send :has_one, name.to_sym, -> { where(attached_as: locale_name.to_s)}, as: poly_sym(type), class_name: type.to_s, dependent: :destroy
      send :accepts_nested_attributes_for, name, allow_destroy: true
      send :define_method, :"#{name}_content", -> { send(name.to_sym).try(:content) }
    end

    def self.define_validations(name, type, validations)
      unique_method_name = "is_#{self.name.underscore}_#{name.to_s}?".to_sym
      slug = @slug
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
