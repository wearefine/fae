module Fae
  class SitesController < Fae::BaseController
    include Fae::InertiaRenderable

    def index
      render_fae_index(
        @klass.for_fae_index,
        columns: { name: 'Name', updated_at: 'Modified' },
        inertia_links: true
      )
    end

    def edit
      render_fae_form(
        param_key: 'site',
        fields: [
          { name: :name, type: :text },
          { name: :netlify_site, type: :text, label: 'Netlify Site Name' },
          { name: :netlify_site_id, type: :text, label: 'Netlify Site ID' },
          { nested_table: :site_deploy_hooks, cols: [:environment, :url], title: 'Deploy Hooks', add_button_text: 'Add Site Deploy Hook' }
        ]
      )
    end

    private

    def set_class_variables(class_name = nil)
      klass_base = 'fae_sites'
      @klass_name = class_name || klass_base               # used in form views
      @klass = Fae::Site             # used as class reference in this controller
      @klass_singular = klass_base.singularize             # used in index views
      @klass_humanized = @klass_name.singularize.humanize  # used in index views
      @index_path = sites_path              # used in form_header partial
      @new_path = @index_path + '/new'                     # used in index_header partial
    end

    def item_params
      params.require(:site).permit!
    end

  end
end
