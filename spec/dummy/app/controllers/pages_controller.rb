class PagesController < ApplicationController
  def home
    @home_page = HomePage.instance
  end
end
