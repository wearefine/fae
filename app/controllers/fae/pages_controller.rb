module Fae
  class PagesController < ApplicationController

    before_filter :authenticate_user!

    def home
      @list = recently_updated
    end

    def help
      require 'browser'
      @browser = Browser.new(ua: request.user_agent, accept_language: 'en-us')
    end

    def error404
      return show_404
    end

  private

    def all_models
      # load of all models since Rails caches activerecord queries.
      Rails.application.eager_load!
      ActiveRecord::Base.descendants.map.reject { |m| m.name['Fae::'] || !m.instance_methods.include?(:fae_display_field) || Fae.dashboard_exclusions.include?(m.name) }
    end

    def recently_updated(num=25)
      list = []
      all_models.each do |m|
        list << m.all.sort_by(&:updated_at).flatten
      end
      list.flatten.sort_by(&:updated_at).reverse.first(num)
    end
  end
end