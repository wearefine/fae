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

    def build_assets
      @item.build_image_en if @item.image_en.blank?
      @item.build_image_frca if @item.image_frca.blank?
      @item.build_pdf_en if @item.pdf_en.blank?
      @item.build_pdf_frca if @item.pdf_frca.blank?
    end
end
