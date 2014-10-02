module Fae
  class PagesController < ApplicationController
    def home
      models = load_all_models
      recently_updated(models, 25)
    end

    def error404
      return show_404
    end


    private


    def load_all_models
      models = []
      Rails.application.eager_load! #fresh load of all models since Rails caches activerecord queries.
      ActiveRecord::Base.descendants.map do |x|
        models << x unless ["ActiveRecord", "Fae::"].any? {|name| x.name.include?(name) }
      end
      models
    end

    def recently_updated(models, num=25)
      @list = []
      models.each do |model|
        @list << model.all.sort_by(&:updated_at).flatten
      end
      @list = @list.flatten.sort_by(&:updated_at).reverse.first(num)
    end
  end
end
