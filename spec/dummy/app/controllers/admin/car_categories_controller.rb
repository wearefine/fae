module Admin
  class CarCategoriesController < Fae::BaseController
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

    def quick_create
      item = CarCategory.new(quick_create_params)
      item.draft = false if item.respond_to?(:draft=)

      if item.save
        render json: {
          id: item.id,
          label: item.fae_display_field.to_s,
          name: item.name.to_s,
          slug: item.slug.to_s
        }, status: :created
      else
        render json: {
          errors: item.errors.to_hash(true),
          messages: item.errors.full_messages
        }, status: :unprocessable_entity
      end
    end



    def self.fae_form_fields
      [
        {
          section: {
            title: 'Main',
            fields: [
              { name: :name, type: :text, slug_source: true },
              { name: :slug, type: :text },
              { name: :image, type: :image, required: true, helper_text: '1200 x 630 px., JPG' }
            ]
          }
        }
      ]
    end


    private

    def quick_create_params
      params.require(:car_category).permit(
        :name,
        :slug,
        image_attributes: [:id, :asset, :alt, :caption, :required]
      )
    end

    def build_assets
      @item.build_image if @item.image.blank?
    end

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
