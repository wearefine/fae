module Fae
  class StaticPage < ActiveRecord::Base
    class << self
      attr_reader :slug
      attr_reader :subclass
      attr_accessor :fields
    end

    def self.instance
      row = find_by_slug(@slug)
      if row.blank?
        row = StaticPage.create(title: @slug.humanize, slug: @slug, subclass: @subclass || "#{@slug.titleize}Page")
        # row.singleton_guard = 0
        # row.save!
      end
      row
    end

    def fields
      {}
    end


  end
end
