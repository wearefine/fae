module Fae
  class UtilitiesController < ApplicationController

    def toggle
      if request.xhr?
        klass = params[:object].gsub('fae_', 'fae/').classify.constantize
        item = klass.find(params[:id])
        item.toggle(params[:attr]).save(validate: false)
      end
      render nothing: true
    end

    def sort
      if request.xhr?
        ids = params[params[:object]]
        params[:object].gsub!('fae_', 'fae/')
        klass = params[:object].classify.constantize
        items = klass.find(ids)
        items.each do |item|
          item.position = ids.index(item.id.to_s) + 1
          item.save
        end
      end
      render nothing: true
    end

  end
end
