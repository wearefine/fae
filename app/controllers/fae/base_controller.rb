module Fae
  class BaseController < ApplicationController

    before_action :set_class_variables
    before_action :set_item, only: [:edit, :update, :destroy, :create_from_existing]

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
      @item = @klass.new(item_params)

      if @item.save
        redirect_to @index_path, notice: t('fae.save_notice')
      else
        build_assets
        flash[:alert] = t('fae.save_error')
        render action: 'new'
      end
    end

    def create_from_existing
      # we should be able to configure which attributes and associations are cloned per object
      @cloned_item = @item.dup
      check_for_unique_validations(@cloned_item.attributes)

      require 'pry'
      binding.pry
      # if @cloned_item.save
      #   sets up associations
      #   # redirects to edit page
      #   render action: 'edit'
      #   # may need to pass in id for new @cloned_item
      # else
      #   build_assets
      #   flash[:alert] = t('fae.save_error')
      #   render action: 'edit'
      # end
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
      if params[:id].present?
        @clone_path = @index_path + '/' + params[:id] + '/create_from_existing' # used in form_buttons partial
      end
      @new_path = @index_path + '/new'                     # used in index_header partial
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = @klass.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def item_params
      params.require(@klass_singular).permit!
    end

    # if model has images or files, build them here for nesting
    def build_assets
    end

    def cloneable_attributes
      # overridable method on BaseController to set cloned attributes and associations (similar to build_assets)
    end

    def check_for_unique_validations(attributes)
      check_for_unique = @klass.validators.collect{|validation| validation if validation.class==ActiveRecord::Validations::UniquenessValidator}.compact.collect(&:attributes).flatten
      attributes.each do |attribute|
        if check_for_unique.include? attribute.first.to_sym
          create_unique_attribute(attribute)
        end
      end
    end

    def create_unique_attribute(attribute)
      index = 2
      symbol = attribute.first.to_sym
      value = attribute.second + '-' + index.to_s

      begin
        record = @klass.where(symbol => value)
        value = value.chomp(index.to_s) + index.to_s
        index = index + 1
      end while record.present?

      @cloned_item[symbol] = value
    end

  end
end