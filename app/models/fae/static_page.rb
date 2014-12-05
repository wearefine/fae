module Fae
  class StaticPage < ActiveRecord::Base

    def self.instance
      row = find_by_slug(@slug)
      if row.blank?
        row = StaticPage.create(title: @slug.titleize, slug: @slug)
      end
      # create has_one associations
      row.fae_fields.each do |key, value|
        row.class.send :has_one, key.to_sym, -> { where(attached_as: key.to_s)}, as: self.poly_sym(value), class_name: value.to_s, dependent: :destroy
        row.class.send :accepts_nested_attributes_for, key, allow_destroy: true
      end
      row
    end

    def fae_fields
      {}
    end

  private

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
