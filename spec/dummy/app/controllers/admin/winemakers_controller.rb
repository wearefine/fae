module Admin
  class WinemakersController < Fae::ApplicationController
    before_action :set_item, only: [:show, :edit, :update, :destroy]

    layout false, except: :index
    helper Fae::ApplicationHelper

    def new
      @item = Winemaker.new
      @item.region_type = params[:region_type] if ['1', '2'].include? params[:region_type]
      @item.wine_id = params[:item_id]
      build_assets
    end

    def edit
      build_assets
    end

    def create
      @item = Winemaker.new(permitted_params)

      if @item.save
        @parent_item = @item.wine
        flash[:notice] = 'Item successfully created.'
        render template: 'admin/winemakers/table'
      else
        build_assets
        render action: 'new'
      end
    end

    def update
      if @item.update(permitted_params)
        @parent_item = @item.wine
        flash[:notice] = 'Item successfully updated.'
        render template: 'admin/winemakers/table'
      else
        build_assets
        render action: 'edit'
      end
    end

    def destroy
      @parent_item = @item.wine

      if @item.destroy
        flash[:notice] = 'Item successfully removed.'
      else
        flash[:alert] = 'There was a problem removing your item.'
      end
      render template: 'admin/winemakers/table'
    end

    private

    def set_item
      @item = Winemaker.find(params[:id])
    end

    def permitted_params
      params.require(:winemaker).permit!
    end

    def build_assets
      @item.build_winemaker_image if @item.winemaker_image.blank?
    end

    def use_pagination
      true
    end

  end
end
