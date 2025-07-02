module Admin
  class SpiritsController < Fae::BaseController

    private

    def build_assets
      @item.build_website_cta if @item.website_cta.blank?
      @item.build_some_other_cta if @item.some_other_cta.blank?
    end

  end
end
