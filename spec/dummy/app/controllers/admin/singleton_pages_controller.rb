module Admin
  class SingletonPagesController < Fae::BaseSingletonController

    private

    def build_assets
      @item.build_image if @item.image.blank?
      @item.build_cta if @item.cta.blank?
    end

  end
end
