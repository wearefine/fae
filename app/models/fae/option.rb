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
      # this grabs the first instance, only one can exist
      begin
        first
      rescue ActiveRecord::RecordNotFound
        # slight race condition here, but it will only happen once if the seed file failed
        row = Option.new({title: 'My FINE Admin'})
        row.singleton_guard = 0
        row.save!
        row
      end
    end
  end
end
