module Fae
  class AltTextsController < ApplicationController

    def index
      @items = Fae::Image.for_fae_index.page(params[:page])
      @parent_model_options = []
      Fae::StaticPage.all.each do |page|
        @parent_model_options << ["#{page.title} Page", "Fae::StaticPage-#{page.id}"]
      end
      Fae::Image.pluck(:imageable_type).uniq.compact.each do |model|
        next if ['Fae::StaticPage', 'Fae::Option'].include?(model)
        @parent_model_options << [model.titleize, model]
      end
    end

    def update_alt
      image = Fae::Image.find_by_id(params[:id])
      image.update_attribute(:alt, params[:alt])
      head :ok
    end

    def filter
      @items = Fae::Image.filter(params).fae_sort(params).page(params[:page])
      render :index, layout: false
    end

  end
end
