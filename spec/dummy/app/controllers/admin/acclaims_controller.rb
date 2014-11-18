class Admin::AcclaimsController < Fae::BaseController
  def build_images
    @item.build_pdf if @item.respond_to?(:pdf) && @item.pdf.blank?
  end
end
