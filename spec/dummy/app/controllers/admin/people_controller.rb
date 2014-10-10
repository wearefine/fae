class Admin::PeopleController < Fae::BaseController

  private

  def build_images
    @item.build_image if @item.respond_to?(:image) && @item.image.blank?
  end

end