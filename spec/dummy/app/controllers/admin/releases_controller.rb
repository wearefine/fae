class Admin::ReleasesController < Fae::BaseController

  def index
    super
    render_alt_view
  end

  def new
    super
    render_alt_view
  end

  def edit
    super
    render_alt_view
  end

  private

  def build_assets
    @item.build_bottle_shot if @item.bottle_shot.blank?
    @item.build_hero_image if @item.hero_image.blank?
    @item.build_label_pdf if @item.label_pdf.blank?
  end

  def attributes_for_cloning
    [:name, :slug, :intro, :body, :wine_id, :release_date]
  end

  def associations_for_cloning
    [:aromas, :events]
  end

  # Test legacy layouts
  # @depreciation - remove after v2.0
  def render_alt_view
    if params[:legacy].present?
      if params[:legacy] == 'old_erb'
        render "admin/releases/old_erb/#{params[:action]}"
      else
        render "admin/releases/old_slim/#{params[:action]}"
      end
    end
  end

end
