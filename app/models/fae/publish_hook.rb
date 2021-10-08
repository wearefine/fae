module Fae
  class PublishHook < ApplicationRecord
    include Fae::BaseModelConcern

    default_scope { order(:name) }

    validates :name, :url, :admin_environment, presence: true
    validates_uniqueness_of :url, :name

    class << self

      def envs_for_select
        ['remote_development', 'production']
      end

      def for_admin_environment
        case Rails.env
        when 'production'
          where(admin_environment: 'production')
        when 'remote_development'
          where(admin_environment: 'remote_development')
        when 'development'
          all
        end
      end

    end

  end
end
