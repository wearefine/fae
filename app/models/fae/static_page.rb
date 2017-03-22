module Fae
  class StaticPage < ActiveRecord::Base

    include Fae::BaseModelConcern
    include Fae::StaticPageConcern

    validates :title, presence: true

    @singleton_is_setup = false

    def self.instance
      setup_dynamic_singleton
      row = left_joins(fae_fields.keys).readonly(false).references(fae_fields.keys).find_by_slug(@slug)
      row = create(title: @slug.titleize, slug: @slug) if row.blank?
      row
    end

    def self.fae_fields
      {}
    end

    def fae_display_field
      title
    end

  private

    def self.setup_dynamic_singleton
      return if @singleton_is_setup

      fae_fields.each do |name, value|
        type = value.is_a?(Hash) ? value[:type] : value
        languages = value.try(:[], :languages)

        if languages.present?
          languages.each do |lang|
            # Save with suffix for form fields
            define_association("#{name}_#{lang}", type)
            define_validations("#{name}_#{lang}", type, value[:validates]) if value.try(:[], :validates).present?
          end
          # Save with lookup to have default language return in front-end use (don't need to worry about validations here)
          default_language = Rails.application.config.i18n.default_locale || languages.first
          define_association(name, type, "#{name}_#{default_language}")
        else
          # Normal content_blocks
          define_association(name, type)
          define_validations(name, type, value[:validates]) if value.try(:[], :validates).present?
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

  end
end
