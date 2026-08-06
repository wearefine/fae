module Admin
  class ArticlesController < Fae::BaseController
    # Fae 5 spike: index and form both render via Inertia + Vue. Most other
    # screens in this app still render Slim, which is the point -- the two
    # coexist during migration.
    include Fae::InertiaRenderable

    def index
      # Articles have always been listed grouped by category rather than as one
      # flat table, and each group reorders on its own.
      categories = ArticleCategory.joins(:articles).distinct.order(:name)

      render_fae_index(
        groups: categories.map { |category| { title: category.name, items: category.articles } },
        columns: { title: 'Title', updated_at: 'Modified' },
        # Safe here because every screen this index links to is converted.
        inertia_links: true
      )
    end

    # #new is inherited: it saves a blank article and redirects here with
    # ?draft=true, which is what puts the form in draft mode.
    def edit
      render_fae_form(fields: form_fields)
    end

    private

    def form_fields
      [
        {
          name: :article_category_id,
          type: :select,
          label: 'Article Category',
          collection: ArticleCategory.order(:name),
          typeahead: true,
          placeholder: 'Select Article Category'
        },
        { name: :title, type: :text },
        { name: :body, type: :textarea }
      ]
    end
  end
end
