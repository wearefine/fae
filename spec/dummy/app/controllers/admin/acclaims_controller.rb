class Admin::AcclaimsController < Fae::BaseController
  before_action do
    # sets custom titles
    set_class_variables 'Reviews'
  end

  def build_assets
    @item.build_pdf if @item.respond_to?(:pdf) && @item.pdf.blank?
  end
end
