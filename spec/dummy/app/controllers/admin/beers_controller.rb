module Admin
  class BeersController < Fae::BaseController
    def index
      render inertia: 'Admin/BeersIndex', props: {
        title: 'Index view overridden in host app',
        newPath: @new_path,
        newButtonText: 'Add a Beer, eh!',
        rows: @klass.for_fae_index.map { |item| beer_index_row(item) }
      }
    end
    include Fae::InertiaRenderable

    def edit
      render_fae_form(
        fields: form_fields
      )
    end

    private

      def beer_index_row(item)
        {
          id: item.id,
          label: item.fae_display_field.to_s,
          editPath: edit_admin_beer_path(item),
          deletePath: admin_beer_path(item),
          modified: helpers.fae_date_format(item.updated_at),
          onStage: !!item.on_stage,
          onProd: !!item.on_prod,
          onStageTogglePath: fae.toggle_path('beers', item.id.to_s, :on_stage),
          onProdTogglePath: fae.toggle_path('beers', item.id.to_s, :on_prod)
        }
      end

    def form_fields
      [
        {
          section: {
            title: 'Main',
            fields: [
              { name: :on_stage, type: :checkbox },
              { name: :on_prod, type: :checkbox },
              { name: :name, type: :text },
              { name: :image, type: :image },
              {
                name: :aroma_ids,
                association: :aromas,
                type: :ranked_select,
                join_model: :beer_aromas,
                label: 'Aromas',
                helper_text: 'Select aromas and drag to rank them in order of prominence.',
                ranking_title: 'Aroma Ranking',
                ranking_helper_text: 'Drag to reorder aromas by prominence',
                preview_image: :image,
                collection: Aroma.for_fae_index
              }
            ]
          }
        },
        {
          section: {
            title: 'Poly Things',
            fields: [
              {
                nested_table: :poly_things,
                cols: [:name_en, :image],
                title: 'Poly Things'
              }
            ]
          }
        }
      ]
    end

    def build_assets
      @item.build_test_cta if @item.test_cta.blank?
      @item.build_image if @item.image.blank?
      if @item.seo.blank?
        @item.build_seo
        @item.seo.build_social_media_image
      end
    end

  end
end
