module Admin
  class ArticleCategoriesController < Fae::BaseController
    # Fae 5 spike: this screen renders via Inertia + Vue. Every other admin
    # screen in this app still renders Slim, which is the point -- the two
    # coexist during migration.
    include Fae::InertiaRenderable

    def index
      render_fae_index(
        @klass.for_fae_index,
        columns: { name: 'Name', updated_at: 'Modified' },
        inertia_links: true
      )
    end

    def edit
      render_fae_form(fields: form_fields)
    end

    private

    def form_fields
      [
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
    end

    def fae_inertia_stay_on_form_after_save?
      true
    end
  end
end
