class Admin::ReleasesController < Fae::BaseController

  private

  def build_assets
    @item.build_bottle_shot if @item.bottle_shot.blank?
    @item.build_label_pdf if @item.label_pdf.blank?
  end

end
