module Fae
  class StaticPagesController < ApplicationController
    before_action :set_class_variables
    before_action :set_item, only: [:edit, :update, :destroy]
    helper FormHelper

    def index
      # override in app
      # @blocks ||= [HomePage, AboutPage]
      # @blocks = [::HomePage]
      @items = blocks.map { |b| b.instance }
    end

    def edit
      return render :edit if params[:id].present?
      build_assocs
      params[:static_page] = true
      render params[:slug]
    end

    # def edit
    #   super
    #   render params[:slug]
    # end

    def update
      # nested attribute not saving as expected. I had to enumerate the item_params hash and manually update the attributes for that association
      # item_params.each do |key, val|
      #   HomePage.instance.send(key.gsub('_attributes', '')).update_attributes(item_params[key]) if key.include? '_attributes'
      # end
      #
      if @item.update(item_params)
        redirect_to @index_path, notice: 'Success. You’ve done good.'
      else
        build_assocs
        render action: 'edit', error: 'Let’s slow down a bit. Check your form for errors.'
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = Fae::StaticPage.find_by_id(params[:id])
    end

    # set up variables so that fae partials for forms work
    def set_class_variables(class_name = nil)
      @klass_name = 'ContentBlocks'
      @klass_singular = @klass_name.singularize
      @klass_humanized = @klass_singular.humanize
      @index_path = "#{Rails.application.routes.url_helpers.fae_path}/#{@klass_name.underscore}"
      @cancelled_path = "#{@index_path}?cancelled=true"
    end

    # Only allow a trusted parameter "white list" through.
    def item_params
      model = @item.class.name.split('::').last.underscore
      params.require(:"#{model}").permit!
      # params.require('home_page').permit!
    end

    # if model has images or files, build them here for nesting
    def build_assocs
      @item.class.fields.each do |key, value|
        @item.class.send :has_one, key.to_sym, -> { where(attached_as: key.to_s)}, as: :contentable, class_name: value.to_s, dependent: :destroy
        @item.class.send :accepts_nested_attributes_for, key, allow_destroy: true
      end

      @item.class.reflect_on_all_associations.each do |assoc|
        # if assoc.options[:class_name].match /(Image|File)/
        #   if @item.send(:"#{assoc.name}").present? ? @item.send(:"#{assoc.name}") : @item.send(:"create_#{assoc.name}")
        # else
        @item.send(:"#{assoc.name}").present? ? @item.send(:"#{assoc.name}") : @item.send(:"create_#{assoc.name}", attached_as: assoc.name.to_s)
        # end
      end
    end

    def blocks
      []
    end
  end
end
