module Admin
  class CarsController < Fae::BaseController
    include Fae::InertiaRenderable


    def index
      render_fae_index(
        @klass.for_fae_index,
        columns: index_columns,
        inertia_links: true
      )
    end


    def edit
      build_assets

      render_fae_form(fields: self.class.fae_form_fields)

    end



    def self.fae_form_fields
      [
        { name: :name_en, type: :text },
        { name: :name_frca, type: :text },
        { name: :name_zh, type: :text },
        { name: :image_en, type: :image },
        { name: :image_frca, type: :image },
        { name: :image_zh, type: :image }
      ]
    end


    private


    def index_columns
      {
        :name_en => 'Name En',
        :updated_at => 'Modified'
      }
    end


    def build_assets
      @item.build_image_en if @item.image_en.blank?
      @item.build_image_frca if @item.image_frca.blank?
      @item.build_image_zh if @item.image_zh.blank?
    end

  end
end
