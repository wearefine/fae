module Admin
  class HeroComponentsController < Fae::FlexComponentBaseController

    def self.fae_form_fields
      [
        { name: :title, type: :text, slug_source: true },
        { name: :slug, type: :text },
        { name: :image, type: :image }
      ]
    end


    private

    def build_assets
      @item.build_image if @item.image.blank?
    end

  end
end