module Admin
  class CatsController < Fae::ApplicationController
    before_action :set_class_variables
    before_action :set_item, only: [:show, :edit, :update, :destroy]

    layout false, except: :index
    helper Fae::ApplicationHelper

    def new
      @item = Cat.new
      @item.aroma_id = params[:item_id]
    end

    def index
      @items = Cat.for_fae_index
    end

    def edit
    end

    def create
      @item = Cat.new(permitted_params)

      if @item.save
        @items = Cat.for_fae_index
        flash[:notice] = 'Item successfully created.'
        render template: 'admin/cats/index'
      else
        render action: 'new'
      end
    end

    def update
      if @item.update(permitted_params)
        @items = Cat.for_fae_index
        flash[:notice] = 'Item successfully updated.'
        render template: 'admin/cats/index'
      else
        render action: 'edit'
      end
    end

    def destroy
      if @item.destroy
        flash[:notice] = 'Item successfully removed.'
      else
        flash[:alert] = 'There was a problem removing your item.'
      end
      @items = Cat.for_fae_index
      render template: 'admin/cats/index'
    end

    private

    def set_class_variables(class_name = nil)
      klass_base = params[:controller].split('/').last
      @klass_name = class_name || klass_base              # used in form views
      @klass = klass_base.classify.constantize            # used as class reference in this controller
      @klass_singular = klass_base.singularize            # used in index views
      @klass_humanized = @klass_name.singularize.humanize # used in index views
      @index_path = '/' + params[:controller]             # used in form_header partial
      @new_path = @index_path + '/new'                    # used in index_header partial
    end

    def set_item
      @item = Cat.find(params[:id])
    end

    def permitted_params
      params.require(:cat).permit!
    end

    def use_pagination
      true
    end

  end
end
