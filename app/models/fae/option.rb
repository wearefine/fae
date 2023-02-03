module Fae
  class Option < ActiveRecord::Base

    include Fae::BaseModelConcern
    include Fae::OptionConcern

    validates_inclusion_of :singleton_guard, :in => [0]
    validates_presence_of :title, :time_zone, :live_url

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

    def fae_tracker_blacklist
      'all'
    end

    def self.instance
      instance = first

      if instance.blank?
        instance = Option.new({title: 'My Fae Admin', time_zone: 'Pacific Time (US & Canada)', live_url: 'http://www.wearefine.com'})
        instance.singleton_guard = 0
        instance.save!
      end

      instance
    end

    class << self

      def set_mfa_enabling_user(email)
        if email.present?
          update(mfa_enabling_user: email)
        else
          update(mfa_enabling_user: "")
        end
      end
      
    end
  end
end
