module Fae
  class PagesController < ApplicationController

    before_action :authenticate_user!

    def home
      @list = recently_updated
      @models = all_models
    end

    def help
      require 'browser'
      @browser = Browser.new(ua: request.user_agent, accept_language: 'en-us')
    end

    def activity_log
      @items = Fae::Change.order(id: :desc).page(params[:page])
    end

    def activity_log_filter
      if params[:commit] == "Reset Search"
        @items = Fae::Change.order(id: :desc).page(params[:page])
      else
        @items = Fae::Change.filter(params).fae_sort(params).page(params[:page])
      end

      render :activity_log, layout: false
    end

    def error404
      return show_404
    end

  private

    def recently_updated(num=25)
      list = []
      all_models.each do |m|
        list << m.all.sort_by(&:updated_at).flatten
      end
      list.flatten.sort_by(&:updated_at).reverse.first(num)
    end
  end
end
