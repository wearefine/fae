class Admin::WinesController < Fae::BaseController

    private

    def use_pagination
      true
    end

    def build_assets
      @item.build_image_en if @item.image_en.blank?
      @item.build_image_frca if @item.image_frca.blank?
    end
end
