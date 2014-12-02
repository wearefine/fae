module Fae
  class StaticPage < ActiveRecord::Base

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


  end
end
