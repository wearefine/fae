module Fae
  class StaticPagesController < ApplicationController
    before_action :set_class_variables
    before_action :set_item, only: [:edit, :update, :destroy]
    helper FormHelper

    def index
      raise 'Missing blocks method inside StaticPages\' child controller' unless fae_pages
      @items = fae_pages.map { |b| b.instance }
    end

    def edit
      build_assocs
      params[:static_page] = true
      render params[:slug]
    end

    def update
      if @item.update(item_params)
        redirect_to @index_path, notice: t('fae.save_notice')
      else
        build_assocs
        render action: 'edit', error: t('fae.save_error')
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = "#{params[:slug].classify}Page".constantize.instance
    end

    # set up variables so that fae partial forms work
    def set_class_variables(class_name = nil)
      @klass_name = class_name || 'Pages'
      @klass_singular = @klass_name.singularize
      @klass_humanized = @klass_singular.humanize
      @index_path = "#{Rails.application.routes.url_helpers.fae_path}/#{@klass_name.underscore.downcase}"
      @cancelled_path = "#{@index_path}?cancelled=true"
    end

    # Only allow a trusted parameter "white list" through.
    def item_params
      model = @item.class.name.split('::').last.underscore
      params.require(:"#{model}").permit!
    end

    def build_assocs
      @item.class.reflect_on_all_associations.each do |assoc|
        @item.send(:"create_#{assoc.name}", attached_as: assoc.name.to_s) if assoc.macro == :has_one && @item.send(:"#{assoc.name}").blank?
      end
    end
  end
end
