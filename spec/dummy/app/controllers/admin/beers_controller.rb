module Admin
  class BeersController < Fae::BaseController

    private

    def build_assets
      @item.build_image if @item.image.blank?
      if @item.seo.blank?
        @item.build_seo
        @item.seo.build_social_media_image
      end
    end

  end
end
