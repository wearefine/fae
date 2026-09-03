module Admin
  class ArticleCategoriesController < Fae::BaseController
    # Renders with Inertia + Vue using the shared Fae form/index serializers.
    include Fae::InertiaRenderable

    def index
      render_fae_index(
        @klass.for_fae_index,
        columns: { name: 'Name', updated_at: 'Modified' },
        inertia_links: true,
        page: 'Admin/ArticleCategories/Index'
      )
    end

    def edit
      render_fae_form(
        fields: form_fields,
        page: 'Admin/ArticleCategories/Form'
      )
    end

    private

    def form_fields
      [
        {
          section: {
            title: 'Main',
            fields: [
              { name: :name, type: :text },
              { name: :name_zh, type: :text },
              { name: :name_frca, type: :text },
              {
                nested_table: :article_subcategories,
                cols: [:name],
                title: 'Article Subcategories'
              },
              {
                flex_components_table: :flex_components,
                title: 'Flex Components'
              }
            ]
          }
        }
      ]
    end

    def fae_inertia_stay_on_form_after_save?
      true
    end
  end
end
