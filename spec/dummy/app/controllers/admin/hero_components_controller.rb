module Admin
  class HeroComponentsController < FlexComponentBaseController


    private

    def build_assets
      @item.build_image if @item.image.blank?
    end

  end
end