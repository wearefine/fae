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
      # the dup method will automatically copy over any foreign_key data, setting up the belongs to relationship
      # check_for_unique_validations(@cloned_item.attributes)
      unique_attributes

      # require 'pry'
      # binding.pry
      # if @cloned_item.save
      #   build_cloneable_attributes
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

    # array of symbols used for setting up associations on cloned object
    def associations_for_cloning
      []
    end

    # array of symbols used for cloning only specific attributes
    def attributes_for_cloning
      []
    end

    #############################################
    ######## special methods for cloning ########
    #############################################

    # set cloneable attributes and associations
    # def build_cloneable_attributes
    #   associations_for_cloning.each do |association|
    #     # dont clone here, just check association and make method for each type
    #     @cloned_item.send(association) = @item.send(association).dup if @item.send(association).present?
    #   end
    # end

    # method to find attrs with unique validators
    def unique_attributes
      attributes = attributes_for_cloning.present? ? attributes_for_cloning : @cloned_item.attributes
      attributes.each do |attribute|
        rename_unique_attribute(attribute) if @klass.validators_on(attribute[0].to_sym).map(&:class).include? ActiveRecord::Validations::UniquenessValidator
      end
    end

    def rename_unique_attribute(attribute)
      index = 2
      symbol = attribute.first.to_sym
      value = attribute.second + '-' + index.to_s

      begin
        record = @klass.where(symbol => value)
        value = value.chomp(index.to_s) + index.to_s
        index += 1
      end while record.present?

      @cloned_item[symbol] = value
    end

  end
end