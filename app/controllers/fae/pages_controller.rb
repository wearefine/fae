module Fae
  class PagesController < ApplicationController
    def home
    end

    def error404
      return show_404
    end
  end
end
