class Admin::LocationsController < Fae::BaseController

  private

  def build_assets
    @item.build_video if @item.video.blank?
    @item.build_image if @item.image.blank?
  end

  def use_pagination
    true
  end
end
