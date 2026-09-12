class Admin::ReleasesController < Fae::BaseController
  include Fae::InertiaRenderable

  def index
    render_fae_index(
      @klass.for_fae_index,
      columns: { name: 'Name', wine: 'Wine', slug: 'Slug', price: 'Price', updated_at: 'Modified', on_stage: 'On Stage', on_prod: 'On Prod' },
      inertia_links: true,
      csv_button: true,
      page: 'Admin/Releases/Index'
    )
  end

  def edit
    render_fae_form(
      fields: form_fields,
      recent_changes: true,
      page: 'Admin/Releases/Form'
    )
  end

  private

  def form_fields
    [
      {
        section: {
          title: 'Attributes',
          fields: [
            { name: :name, type: :text, slug_source: true },
            { name: :vintage, type: :text, helper_text: 'Text input' },
            { name: :slug, type: :text },
            { name: :is_something, type: :checkbox },
            { name: :seo_title, type: :text },
            { name: :seo_description, type: :text },
            { name: :intro, type: :textarea, markdown: true },
            { name: :body, type: :textarea, label: 'Body Content' },
            { name: :description, type: :textarea, markdown: true },
            { name: :content, type: :textarea },
            { name: :price, type: :text },
            { name: :weight, type: :text },
            { name: :video_url, type: :text },
            { name: :featured, type: :checkbox },
            { name: :on_stage, type: :checkbox },
            { name: :on_prod, type: :checkbox },
            { name: :release_date, type: :date },
            { name: :show, type: :date },
            { name: :hide, type: :date },
            { name: :color, type: :text }
          ]
        }
      },
      {
        section: {
          title: 'Assets',
          fields: [
            { name: :bottle_shot, type: :image, helper_text: 'Image with alt text' },
            { name: :hero_image, type: :image, helper_text: 'Image with alt text and caption', show_caption: true },
            { name: :label_pdf, type: :file }
          ]
        }
      },
      {
        section: {
          title: 'Associations',
          fields: [
            { name: :varietal_id, type: :select, collection: Varietal.for_fae_index },
            { name: :wine_id, type: :grouped_select, groups: grouped_wines, required: true },
            { name: :acclaim_ids, type: :multiselect, collection: Acclaim.for_fae_index },
            { name: :selling_point_ids, type: :two_pane_multiselect, collection: SellingPoint.for_fae_index },
            { name: :event_ids, type: :multiselect, collection: Event.for_fae_index }
          ]
        }
      }
    ]
  end

  def grouped_wines
    Wine.order(:name_en).group_by do |wine|
      wine.name_en.to_s.first.to_s.upcase.presence || '#'
    end
  end

  def build_assets
    @item.build_bottle_shot if @item.bottle_shot.blank?
    @item.build_hero_image if @item.hero_image.blank?
    @item.build_label_pdf if @item.label_pdf.blank?
  end

  def attributes_for_cloning
    [:name, :slug, :intro, :body, :wine_id, :release_date]
  end

  def associations_for_cloning
    [:aromas, :events, :bottle_shot, :label_pdf]
  end

  def use_pagination
    true
  end

  def fae_inertia_stay_on_form_after_save?
    true
  end

end
