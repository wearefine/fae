module Admin
  class ArticleSubcategoriesController < Fae::NestedBaseController

    private

    def build_assets
      @item.build_video if @item.video.blank?
    end

  end
end
