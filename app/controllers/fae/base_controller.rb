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
      @cloned_item = @item.dup
      # the dup method will automatically copy over any foreign_key data, setting up the belongs to relationship
      attributes = attributes_for_cloning.present? ? attributes_for_cloning : @cloned_item.attributes
      find_unique_attributes(attributes, @cloned_item)

      if @cloned_item.save
        find_cloneable_attributes
        redirect_to @index_path + '/' + @cloned_item.id.to_s + '/edit'
        #   # may need to pass in id for new @cloned_item
        # else
        #   build_assets
        #   flash[:alert] = t('fae.save_error')
        #   render action: 'edit'
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
    def find_cloneable_attributes
      associations_for_cloning.each do |association|
        type = @klass.reflect_on_association(association)
        through_record = type.through_reflection

        if through_record.present?
          clone_join_relationships(through_record.plural_name)
        else
          clone_has_many_relationships(association) if type.macro == :has_many
          clone_has_one_relationship(association)  if type.macro == :has_one
        end
      end
    end

    def clone_has_many_relationships(association)
      if @item.send(association).present?
        @item.send(association).each do |record|
          new_record = @item.send(association).where(id: record.id).dup
          # check if associations have unique attributes
          find_unique_attributes(new_record.attributes, new_record)

          @cloned_item.send(association) << new_record
        end
      end
    end

    def clone_has_one_relationship(association)
      @cloned_item.send("build_#{association}") if @cloned_item.send(association).blank?
      @cloned_item.send(association) << @item.send(association).dup if @item.send(association).present?
      # TODO - if Fae::Image or Fae::File, need to duplicate assets as well
    end

    def clone_join_relationships(object)
      if @item.send(object.to_sym).present?
        @item.send(object.to_sym).each do |record|
          copied_join = object.classify.constantize.find(record.id).dup
          copied_join.send("#{@klass_singular}_id" + '=', @cloned_item.id)
          @cloned_item.send(object.to_sym) << copied_join
        end
      end
    end

    # method to find attrs with unique validators
    def find_unique_attributes(attributes, item)
      attributes.each do |attribute|
        rename_unique_attribute(attribute, item) if @klass.validators_on(attribute[0].to_sym).map(&:class).include? ActiveRecord::Validations::UniquenessValidator
      end
    end

    def rename_unique_attribute(attribute, item)
      index = 2
      symbol = attribute.first.to_sym
      value = attribute.second + '-' + index.to_s

      begin
        record = @klass.where(symbol => value)
        unless record.empty?
          new_index = index + 1
          value = value.chomp(index.to_s) + new_index.to_s
          index = new_index
        end
      end while record.present?

      item[symbol] = value
    end

  end
end