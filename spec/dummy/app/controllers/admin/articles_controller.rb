module Admin
  class ArticlesController < Fae::BaseController

    def index
      @article_categories = ArticleCategory.joins(:articles).uniq
    end

  end
end
