module Admin
  class SpiritsController < Fae::BaseController
    # Index and form render via Inertia + Vue and include a nested table;
    # see nested_tables below and Admin::SubSpiritsController.
    include Fae::InertiaRenderable

    def index
      render_fae_index(
        @klass.for_fae_index,
        columns: { name: 'Name', date: 'Date', updated_at: 'Modified' },
        inertia_links: true
      )
    end

    def edit
      render_fae_form(
        fields: [
          {
            section: {
              title: 'Main',
              fields: [
                { name: :name, type: :text },
                { name: :logo, type: :image, helper_text: '1200 x 630 px., JPG' },
                { name: :date, type: :date },
                { name: :description, type: :textarea, markdown: true },
                { name: :pdf_upload, type: :file, label: 'PDF Upload' }
              ]
            }
          },
          {
            section: {
              title: 'Sub Spirits',
              # The sub-spirit form's fields are declared by its own controller,
              # so this only names the association and listed columns.
              fields: [
                { nested_table: :sub_spirits, cols: [:name] }
              ]
            }
          }
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

    def fae_inertia_stay_on_form_after_save?
      true
    end

  end
end
