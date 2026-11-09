module Admin
  class HeroComponentsController < Fae::FlexComponentBaseController


    private

    def build_assets
      @item.build_image if @item.image.blank?
      @item.build_video if @item.video.blank?
    end

  end
end