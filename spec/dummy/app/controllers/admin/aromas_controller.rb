module Admin
  class AromasController < Fae::ApplicationController
    before_action :set_item, only: [:show, :edit, :update, :destroy]

    layout false, except: :index
    helper Fae::ApplicationHelper

    def new
      @item = Aroma.new
      @item.release_id = params[:item_id]
      build_assets
    end

    def edit
      build_assets
    end

    def create
      @item = Aroma.new(permitted_params)

      if @item.save
        @parent_item = @item.release
        flash[:notice] = 'Item successfully created.'
        render template: 'admin/aromas/table'
      else
        build_assets
        render action: 'new'
      end
    end

    def update
      if @item.update(permitted_params)
        @parent_item = @item.release
        flash[:notice] = 'Item successfully updated.'
        render template: 'admin/aromas/table'
      else
        build_assets
        render action: 'edit'
      end
    end

    def destroy
      @parent_item = @item.release

      if @item.destroy
        flash[:notice] = 'Item successfully removed.'
      else
        flash[:alert] = 'There was a problem removing your item.'
      end
      render template: 'admin/aromas/table'
    end

    private

    def set_item
      @item = Aroma.find(params[:id])
    end

    def permitted_params
      params.require(:aroma).permit!
    end

    def build_assets
      @item.build_image if @item.image.blank?
    end

  end
end
