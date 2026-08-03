module Admin
  class SpiritsController < Fae::BaseController
    # Fae 5 spike: index and form both render via Inertia + Vue. This is the
    # first converted screen with a nested table -- see nested_tables below and
    # Admin::SubSpiritsController.
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
        fields: [
          { name: :name, type: :text },
          { name: :logo, type: :image, helper_text: '1200 x 630 px., JPG' },
          # The sub-spirit form's fields are declared by its own controller, so
          # this only names the association and the columns to list. It sits
          # between the inputs here because that is where the form declares it.
          { nested_table: :sub_spirits, cols: [:name] },
          { name: :description, type: :textarea, markdown: true },
          { name: :pdf_upload, type: :file, label: 'PDF Upload', helper_text: 'PDF, 5 MB max.' }
        ]
      )
    end

    private

    def build_assets
      @item.build_website_cta if @item.website_cta.blank?
      @item.build_some_other_cta if @item.some_other_cta.blank?
      @item.build_logo if @item.logo.blank?
      @item.build_pdf_upload if @item.pdf_upload.blank?
    end

  end
end
