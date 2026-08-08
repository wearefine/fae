module Admin
  class WidgetsController < Fae::BaseController
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
        { name: :name, type: :text }
      ]
    end


    private


    def index_columns
      {
        :name => 'Name',
        :updated_at => 'Modified',
        :on_stage => 'On Stage',
        :on_prod => 'On Prod'
      }
    end


  end
end
