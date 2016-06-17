module Fae
  class BaseController < ApplicationController
    include Fae::Cloneable

    before_action :set_class_variables
    before_action :set_item, only: [:edit, :update, :destroy]
    before_action :authorize_user

    helper FormHelper

    def index
      @items = @klass.for_fae_index
      respond_to do |format|
        format.html
        format.csv { send_data @items.to_csv, filename: @items.name.parameterize + "." + Time.now.to_s(:filename) + '.csv'  }
      end
    end

    def new
      @item = @klass.new
      build_assets
    end

    def edit
      build_assets
    end

    def create
      return create_from_existing(params[:from_existing]) if params[:from_existing].present?

      @item = @klass.new(item_params)

      if @item.save
        redirect_to @index_path, notice: t('fae.save_notice')
      else
        build_assets
        flash[:alert] = t('fae.save_error')
        render action: 'new'
      end
    end

    def update
      if @item.update(item_params)
        redirect_to @index_path, notice: t('fae.save_notice')
      else
        build_assets
        flash[:alert] = t('fae.save_error')
        render action: 'edit'
      end
    end

    def destroy
      if @item.destroy
        redirect_to @index_path, notice: t('fae.delete_notice')
      else
        redirect_to @index_path, flash: { error: t('fae.delete_error') }
      end
    end

    def filter
      if params[:commit] == "Reset Search"
        @items = @klass.filter_all
      else
        @items = @klass.filter(params[:filter])
      end

      render :index, layout: false
    end

  private

    def set_class_variables(class_name = nil)
      klass_base = params[:controller].split('/').last
      @klass_name = class_name || klass_base               # used in form views
      @klass = klass_base.classify.constantize             # used as class reference in this controller
      @klass_singular = klass_base.singularize             # used in index views
      @klass_humanized = @klass_name.singularize.humanize  # used in index views
      @index_path = '/' + params[:controller]              # used in form_header and form_buttons partials
      @new_path = @index_path + '/new'                     # used in index_header partial
    end

    # use callbacks to share common setup or constraints between actions.
    def set_item
      @item = @klass.find(params[:id])
    end

    # only allow trusted parameters, override to white-list
    def item_params
      params.require(@klass_singular).permit!
    end

    # if model has images or files, build them here for nesting
    def build_assets
    end

    def authorize_user
      roles_for_controller = Fae::Authorization.access_map[params[:controller].gsub('admin/','')]
      return if current_user.super_admin? || roles_for_controller.blank?
      return show_404 unless roles_for_controller.include?(current_user.role.name)
    end

  end
end