module Fae
  class StaticPage < ActiveRecord::Base
    include Fae::Concerns::Models::Base

    def self.instance
      set_assocs
      row = includes(fae_fields.keys).references(fae_fields.keys).find_by_slug(@slug)
      row = StaticPage.create(title: @slug.titleize, slug: @slug) if row.blank?
      row
    end

    def self.fae_fields
      {}
    end

  private

    def self.set_assocs
      # create has_one associations
      fae_fields.each do |key, value|
        send :has_one, key.to_sym, -> { where(attached_as: key.to_s)}, as: poly_sym(value), class_name: value.to_s, dependent: :destroy
        send :accepts_nested_attributes_for, key, allow_destroy: true
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
