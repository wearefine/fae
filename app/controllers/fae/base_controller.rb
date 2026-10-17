module Fae
  class BaseController < ApplicationController
    include Fae::Cloneable

    before_action :set_class_variables
    before_action :set_item, only: [:edit, :update, :destroy]
    before_action :authorize_user

    helper FormHelper

    def index
      @items = index_scope
      respond_to do |format|
        format.html
        format.csv { send_data @items.to_csv, filename: @items.name.parameterize + "." + Time.now.to_fs(:filename) + '.csv'  }
      end
    end

    def new
      @item = @klass.new
      assign_parent_to_item
      @item.draft = true if @klass.has_fae_draft_support?
      @item.save(validate: false)
      if @item.is_a?(Fae::Site)
        redirect_to fae.edit_site_path(id: @item.id, draft: true)
      else
        redirect_to build_edit_path(@item, draft: true)
      end
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
        flash.now[:alert] = t('fae.save_error')
        render action: 'new', status: 422
      end
    end

    def update
      @item.draft = false if @klass.has_fae_draft_support?
      if @item.update(item_params)
        redirect_to @index_path, notice: t('fae.save_notice')
      else
        build_assets
        flash.now[:alert] = t('fae.save_error')
        render action: 'edit', status: 422
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
      if use_pagination
        @items = @klass.filter(params).fae_sort(params).page(params[:page])
      else
        @items = @klass.filter(params).fae_sort(params)
      end

      render :index, layout: false
    end

    def show
      # show action is hidden by default, override as needed
      show_404
    end

  private

    # Index results, honoring the query string that filter forms in a Turbo frame (`fae_filter_frame`) build:
    # `filter[...]` for the filters and `sort_by`, `sort_direction` and `page` for sorting and paging. It uses the
    # same `filter(params)` and `fae_sort(params)` class methods as the POST `filter` action, so the same model code
    # serves both. Without those params, it's the plain index it always was.
    def index_scope
      scope = filter_query? ? @klass.filter(flat_filter_params).fae_sort(flat_filter_params) : @klass.for_fae_index
      use_pagination ? scope.page(params[:page]) : scope
    end

    def filter_query?
      params[:filter].present? || params[:sort_by].present?
    end

    # Models read filters as top-level params (`params['search']`), the way the filter action receives them
    def flat_filter_params
      nested = params[:filter].respond_to?(:to_unsafe_h) ? params[:filter].to_unsafe_h : {}
      ActionController::Parameters.new(params.to_unsafe_h.except('filter').merge(nested))
    end

    def set_class_variables(class_name = nil)
      klass_base = params[:controller].split('/').last
      @klass_name = class_name || klass_base               # used in form views
      @klass = klass_base.classify.constantize             # used as class reference in this controller
      @klass_singular = klass_base.singularize             # used in index views
      @klass_humanized = @klass_name.singularize.humanize  # used in index views
      @index_path = '/' + params[:controller]              # used in form_header partial
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

    # allows this controller to use pagination
    def use_pagination
      false
    end

    # Detect parent resource from params (e.g., team_id for nested coaches)
    def parent_resource_param
      params.keys.find { |key| key.to_s.end_with?('_id') && key.to_s != 'id' }
    end

    # Get the parent resource name (e.g., 'team' from 'team_id')
    def parent_resource_name
      parent_resource_param&.to_s&.sub(/_id$/, '')
    end

    # Assign parent association to item for nested resources
    def assign_parent_to_item
      if parent_resource_param && @item.respond_to?("#{parent_resource_name}_id=")
        @item.send("#{parent_resource_name}_id=", params[parent_resource_param])
      end
    end

    # Build the edit path, handling nested resources
    def build_edit_path(item, options = {})
      if parent_resource_param
        # Nested resource: e.g., edit_admin_team_coach_path(team_id, coach_id)
        send("edit_admin_#{parent_resource_name}_#{@klass_singular}_path", params[parent_resource_param], item.id, options)
      else
        # Non-nested resource: e.g., edit_admin_person_path(id)
        send("edit_admin_#{@klass_singular}_path", item.id, options)
      end
    end

  end
end