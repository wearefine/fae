module Fae
  class Option < ActiveRecord::Base

    validates_inclusion_of :singleton_guard, :in => [0]
    validates_presence_of :title, :time_zone, :colorway, :live_url

    has_one :logo, -> { where(attached_as: 'logo' ) },
      as: :imageable,
      class_name: 'Fae::Image',
      dependent: :destroy
    accepts_nested_attributes_for :logo, allow_destroy: true

    has_one :favicon, -> { where(attached_as: 'favicon' ) },
      as: :imageable,
      class_name: 'Fae::Image',
      dependent: :destroy
    accepts_nested_attributes_for :favicon, allow_destroy: true

    def self.instance
      # there will be only one row, and its ID must be '1'
      begin
        first
      rescue ActiveRecord::RecordNotFound
        # slight race condition here, but it will only happen once
        row = Option.new({title: 'My FINE Admin'})
        row.build_logo
        row.build_favicon
        row.singleton_guard = 0
        row.save!
        row
      end
    end
  end
end
