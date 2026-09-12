module Admin
  class TrucksController < Fae::BaseController
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

      render_fae_form(
        fields: self.class.fae_form_fields,
        page: 'Admin/Trucks/Form'
      )

    end



    def self.fae_form_fields
      [
        {
          section: {
            title: 'Main',
            fields: [
              { name: :name, type: :text, slug_source: true },
              { name: :slug, type: :text },
              { name: :image, type: :image }
            ]
          }
        }
      ]
    end


    private


    def index_columns
      {
        :name => 'Name',
        :updated_at => 'Modified'
      }
    end


    def build_assets
      @item.build_image if @item.image.blank?
    end

  end
end
