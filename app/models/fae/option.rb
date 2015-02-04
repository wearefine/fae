module Fae
  class Option < ActiveRecord::Base

    include Fae::OptionConcern

    validates_inclusion_of :singleton_guard, :in => [0]
    validates_presence_of :title, :time_zone

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
      instance = first

      if instance.blank?
        instance = Option.new({title: 'My FINE Admin', time_zone: 'Pacific Time (US & Canada)'})
        instance.singleton_guard = 0
        instance.save!
      end

      instance
    end
  end
end
