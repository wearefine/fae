module Admin
  class ArticleCategoriesController < Fae::BaseController
    # Fae 5 spike: this screen renders via Inertia + Vue. Every other admin
    # screen in this app still renders Slim, which is the point -- the two
    # coexist during migration.
    include Fae::InertiaRenderable

    def index
      render_fae_index(
        @klass.for_fae_index,
        columns: { name: 'Name', updated_at: 'Modified' }
      )
    end
  end
end
