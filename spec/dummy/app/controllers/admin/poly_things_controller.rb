module Admin
  class PolyThingsController < Fae::NestedBaseController


    def new
      @item = @klass.new
      raise_undefined_parent if @item.fae_nested_foreign_key.blank?

      item_id = params[:item_id].to_i || nil
      item_class = params[:item_class] || nil
      @item.send("poly_thingable_id=", item_id)
      @item.send("poly_thingable_type=", item_class)
      build_assets
    end



  end
end
