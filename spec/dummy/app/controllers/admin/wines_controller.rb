class Admin::WinesController < Fae::BaseController
  include Fae::InertiaRenderable

  def index
    render_fae_index(
      @klass.for_fae_index,
      columns: { name_en: 'Name', updated_at: 'Modified', on_stage: 'On Stage', on_prod: 'On Prod' },
      inertia_links: true,
      page: 'Admin/Wines/Index'
    )
  end

  def edit
    render_fae_form(fields: form_fields, page: 'Admin/Wines/Form')
  end

  private

  def form_fields
    [
      {
        section: {
          title: 'Content',
          fields: [
            { name: :name_en, type: :text },
            { name: :name_zh, type: :text },
            { name: :name_frca, type: :text },
            { name: :description_en, type: :textarea },
            { name: :description_zh, type: :textarea },
            { name: :description_frca, type: :textarea },
            { name: :food_pairing_en, type: :textarea },
            { name: :food_pairing_zh, type: :textarea },
            { name: :food_pairing_ja, type: :textarea }
          ]
        }
      },
      {
        section: {
          title: 'Oregon Winemakers',
          show_title: false,
          fields: [
            {
              nested_table: :oregon_winemakers,
              controller: :winemakers,
              param_key: :winemaker,
              extra_hidden: { region_type: 1 },
              cols: [:name, :winemaker_image, :table_image],
              title: 'Oregon Winemakers'
            }
          ]
        }
      },
      {
        section: {
          title: 'California Winemakers',
          show_title: false,
          fields: [
            {
              nested_table: :california_winemakers,
              controller: :winemakers,
              param_key: :winemaker,
              extra_hidden: { region_type: 2 },
              cols: [:name, :winemaker_image, :table_image],
              title: 'California Winemakers'
            }
          ]
        }
      },
      {
        section: {
          title: 'Calls to Action',
          fields: [
            { name: :test_cta_en, type: :cta, label: 'Test CTA (English)' },
            { name: :test_cta_zh, type: :cta, label: 'Test CTA (Chinese)' },
            { name: :test_cta_ja, type: :cta, label: 'Test CTA (Japanese)' }
          ]
        }
      },
      {
        section: {
          title: 'Associations',
          fields: [
            { name: :release_ids, type: :multiselect, collection: Release.for_fae_index }
          ]
        }
      },
      {
        section: {
          title: 'Components',
          show_title: false,
          fields: [
            { flex_components_table: :flex_components, title: 'Components' }
          ]
        }
      },
      {
        section: {
          title: 'Assets',
          fields: [
            { name: :image_en, type: :image },
            { name: :image_frca, type: :image },
            { name: :pdf_en, type: :file },
            { name: :pdf_frca, type: :file }
          ]
        }
      }
    ]
  end

  def use_pagination
    true
  end

  def build_assets
    @item.build_test_cta_en if @item.test_cta_en.blank?
    @item.build_test_cta_zh if @item.test_cta_zh.blank?
    @item.build_test_cta_ja if @item.test_cta_ja.blank?
    @item.build_image_en if @item.image_en.blank?
    @item.build_image_frca if @item.image_frca.blank?
    @item.build_pdf_en if @item.pdf_en.blank?
    @item.build_pdf_frca if @item.pdf_frca.blank?
  end

  def fae_inertia_stay_on_form_after_save?
    true
  end
end
