module Admin
  class ListItemsController < Fae::NestedBaseController



    private

    def build_assets
      @item.build_image if @item.image.blank?
    end

  end
end