class Admin::WinesController < Fae::BaseController

    private

    def build_assets
      @item.build_test_cta_en if @item.test_cta_en.blank?
      @item.build_test_cta_zh if @item.test_cta_zh.blank?
      @item.build_test_cta_ja if @item.test_cta_ja.blank?
    end

    def use_pagination
      true
    end
end
