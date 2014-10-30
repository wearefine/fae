module Fae
  class PagesController < ApplicationController

    before_filter :authenticate_user!

    def home
      @models = load_all_models
      @list = recently_updated
    end

    def error404
      return show_404
    end

  private

    def load_all_models
      # load of all models since Rails caches activerecord queries.
      Rails.application.eager_load!
      ActiveRecord::Base.descendants.map.reject { |m| m.name['::'] || !m.instance_methods.include?(:display_field) }
    end

    def recently_updated(num=25)
      list = []
      @models.each do |m|
        list << m.all.sort_by(&:updated_at).flatten
      end
      list.flatten.sort_by(&:updated_at).reverse.first(num)
    end
  end
end