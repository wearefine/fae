module Fae
  class AltTextsController < ApplicationController

    def index
      @items = Fae::Image.for_fae_index.page(params[:page])
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
