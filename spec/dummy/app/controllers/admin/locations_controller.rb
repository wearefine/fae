class Admin::LocationsController < Fae::BaseController

  private

  def build_assets
    @item.build_video if @item.video.blank?
  end

  def use_pagination
    true
  end
end
