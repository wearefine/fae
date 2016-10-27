module Admin
  class AromasController < Fae::NestedBaseController

    private

    def build_assets
      @item.build_image if @item.image.blank?
    end

    def use_pagination
      true
    end


  end
end
