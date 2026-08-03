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
      @items = Fae::Change.order(id: :desc).page(params[:page])
    end

    def activity_log_filter
      if params[:commit] == "Reset Search"
        @items = Fae::Change.order(id: :desc).page(params[:page])
      else
        @items = Fae::Change.filter(params).fae_sort(params).page(params[:page])
      end

      render :activity_log, layout: false
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
  end
end
