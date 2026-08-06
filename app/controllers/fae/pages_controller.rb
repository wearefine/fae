module Fae
  class PagesController < ApplicationController
    include Fae::InertiaRenderable

    before_action :authenticate_user!

    def home
      @list = recently_updated
      @models = all_models

      render inertia: 'Fae/Dashboard', props: {
        greeting: t('fae.page.hello'),
        userName: current_user.full_name,
        columns: [
          { key: 'name', label: t('fae.common.name') },
          { key: 'type', label: t('fae.changes.type') },
          { key: 'updatedAt', label: t('fae.changes.modified') }
        ],
        rows: dashboard_rows,
        emptyState: {
          title: t('fae.page.welcome'),
          body: t('fae.page.no_objs_start'),
          linkText: t('fae.page.no_objs_end'),
          linkUrl: 'https://www.faecms.com/documentation/quickstart-guide'
        }
      }
    end

    def help
      require 'browser'
      @browser = Browser.new(request.user_agent, accept_language: 'en-us')
    end

    def activity_log
      @items = fae_activity_log_relation.page(params[:page])

      render inertia: 'Fae/ActivityLog', props: {
        title: t('fae.application.activity_log_heading'),
        indexPath: fae.activity_log_path,
        filters: {
          title: t('fae.changes.title'),
          fields: fae_activity_log_filter_fields,
          values: fae_activity_log_filter_values
        },
        sort: {
          by: params[:sort_by].to_s,
          direction: params[:sort_direction].presence || 'asc'
        },
        rows: @items.map { |change| fae_activity_log_row(change) },
        pagination: {
          currentPage: @items.current_page,
          totalPages: @items.total_pages,
          totalCount: @items.total_count,
          perPage: Fae.per_page,
          prevPage: @items.prev_page,
          nextPage: @items.next_page
        },
        emptyText: t('fae.changes.no_changes')
      }
    end

    def activity_log_filter
      if request.inertia?
        redirect_to fae.activity_log_path(fae_activity_log_filter_values.merge(page: params[:page]).compact)
      else
        if params[:commit] == "Reset Search"
          @items = Fae::Change.order(id: :desc).page(params[:page])
        else
          @items = Fae::Change.filter(params).fae_sort(params).page(params[:page])
        end

        render :activity_log, layout: false
      end
    end

    def error404
      return show_404
    end

  private

    # Mirrors the rescue the Slim dashboard wrapped each row in: a model can
    # appear in all_models without having the routes these paths need, and one
    # such model should not take the whole dashboard down.
    def dashboard_rows
      return [] if @models.blank?

      @list.filter_map do |item|
        begin
          parent = item.respond_to?(:fae_parent) ? item.fae_parent : nil
          type = item.class.to_s

          {
            id: "#{type}-#{item.id}",
            name: item.fae_display_field,
            editPath: edit_polymorphic_path([main_app, helpers.fae_scope.to_sym, parent, item]),
            type: type,
            typePath: polymorphic_path([main_app, helpers.fae_scope.to_sym, parent, type.pluralize.underscore.to_sym]),
            updatedAt: helpers.fae_date_format(item.updated_at)
          }
        rescue StandardError
          nil
        end
      end
    end

    def recently_updated(num=25)
      list = []
      all_models.each do |m|
        list << m.all.sort_by(&:updated_at).flatten
      end
      list.flatten.sort_by(&:updated_at).reverse.first(num)
    end

    def fae_activity_log_relation
      values = fae_activity_log_filter_values
      scope = values.values.any?(&:present?) ? Fae::Change.filter(values) : Fae::Change.order(id: :desc)
      scope.fae_sort(params)
    end

    def fae_activity_log_filter_values
      params.permit(:type, :start_date, :end_date, :date, :user, :model, :search, :sort_by, :sort_direction).to_h
    end

    def fae_activity_log_filter_fields
      [
        {
          key: 'type',
          label: t('fae.changes.models.type', default: 'Type'),
          type: 'select',
          placeholder: t('fae.all_items', items: t('fae.changes.type').pluralize),
          options: [
            { label: t('fae.changes.created'), value: t('fae.changes.created') },
            { label: t('fae.changes.updated'), value: t('fae.changes.updated') },
            { label: t('fae.changes.deleted'), value: t('fae.changes.deleted') }
          ]
        },
        {
          key: 'start_date',
          label: 'Start Date',
          type: 'text',
          placeholder: 'MM/DD/YYYY'
        },
        {
          key: 'end_date',
          label: 'End Date',
          type: 'text',
          placeholder: 'MM/DD/YYYY'
        },
        {
          key: 'date',
          label: 'Date',
          type: 'select',
          placeholder: t('fae.changes.all_time'),
          options: [
            { label: t('fae.changes.last_hour'), value: t('fae.changes.last_hour') },
            { label: t('fae.changes.last_day'), value: t('fae.changes.last_day') },
            { label: t('fae.changes.last_week'), value: t('fae.changes.last_week') },
            { label: t('fae.changes.last_month'), value: t('fae.changes.last_month') }
          ]
        },
        {
          key: 'user',
          label: t('fae.changes.user'),
          type: 'select',
          placeholder: t('fae.all_items', items: t('fae.changes.user').pluralize),
          options: Fae::User.all.map { |user| { label: user.full_name, value: user.id } }
        },
        {
          key: 'model',
          label: t('fae.changes.item'),
          type: 'select',
          placeholder: t('fae.all_items', items: t('fae.changes.item').pluralize),
          options: Fae::Change.unique_changeable_types.map { |label, value| { label: label, value: value } }
        }
      ]
    end

    def fae_activity_log_row(change)
      item = fae_activity_log_item_link(change)

      {
        id: change.id,
        user: change.user&.full_name.to_s,
        itemText: item[:text],
        itemPath: item[:path],
        type: change.change_type,
        attrs: Array(change.updated_attributes).join(', '),
        modified: helpers.fae_datetime_format(change.updated_at)
      }
    end

    def fae_activity_log_item_link(change)
      type = change.changeable_type.to_s
      text = "#{type.gsub('Fae::', '')}: "

      display = change.try(:changeable).try(:fae_display_field)
      display = display.is_a?(Integer) ? display.to_s : display
      text += display || "##{change.changeable_id}"

      return { text: text, path: nil } if change.changeable.blank?

      begin
        if type == 'Fae::StaticPage'
          return { text: text, path: fae.edit_content_block_path(change.changeable.slug) }
        end

        parent = change.changeable.respond_to?(:fae_parent) ? change.changeable.fae_parent : nil
        path = edit_polymorphic_path([main_app, helpers.fae_scope.to_sym, parent, change.changeable])
        { text: text, path: path }
      rescue StandardError
        { text: text, path: nil }
      end
    end
  end
end
