module Fae
  class StaticPage < ActiveRecord::Base

    after_initialize :set_assocs

    def self.instance
      row = find_by_slug(@slug)
      if row.blank?
        row = StaticPage.create(title: @slug.titleize, slug: @slug)
      end
      row
    end

    def fae_fields
      {}
    end

  private

    def set_assocs
      # create has_one associations
      self.fae_fields.each do |key, value|
        self.class.send :has_one, key.to_sym, -> { where(attached_as: key.to_s)}, as: poly_sym(value), class_name: value.to_s, dependent: :destroy
        self.class.send :accepts_nested_attributes_for, key, allow_destroy: true
      end
    end

    def poly_sym(assoc)
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
