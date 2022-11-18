module Admin
  class BeersController < Fae::BaseController

    private

    def build_assets
      if @item.seo.blank?
        @item.build_seo
        @item.seo.build_social_media_image
      end
    end

  end
end
