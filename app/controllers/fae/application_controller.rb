module Fae
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    include Fae::ApplicationControllerConcern

    helper Fae::ViewHelper
    helper Fae::FormHelper
    helper Fae::NestedFormHelper
    helper Fae::FaeHelper

    before_action :check_disabled_environment
    before_action :first_user_redirect
    before_action :authenticate_user!
    before_action :build_nav
    before_action :set_option
    before_action :detect_cancellation
    before_action :set_change_user
    before_action :set_locale

    private

    def set_locale
      I18n.locale = :en
    end

    def check_disabled_environment
      disabled_envs = Fae.disabled_environments.map { |e| e.to_s }
      return unless disabled_envs.include? Rails.env.to_s
      render template: 'fae/pages/disabled_environment.html.slim', layout: 'fae/error.html.slim'
    end

    def super_admin_only
      redirect_to fae.root_path, flash: { error: t('fae.unauthorized_error') } unless current_user.super_admin?
    end

    def admin_only
      redirect_to fae.root_path, flash: { error: t('fae.unauthorized_error') } unless current_user.super_admin? || current_user.admin?
    end

    def show_404
      render template: 'fae/pages/error404.html.slim', layout: 'fae/error.html.slim', status: :not_found
    end

    def set_option
      @option = Fae::Option.instance
    end

    def detect_cancellation
      flash.now[:warning] = 'Your changes were not saved.' if params[:cancelled].present? && params[:cancelled]== "true"
    end

    def build_nav
      return unless current_user

      # shameless green: if we continue to cache specific parts of Fae we should either:
      # - create support methods to DRY this conditional logic
      # - explore using `expires_in: 0` as a way to ignore caching
      if Fae.use_cache
        @fae_navigation = Rails.cache.fetch("fae_navigation_#{current_user.role.id}") do
          Fae::Navigation.new(current_user)
        end
      else
        @fae_navigation = Fae::Navigation.new(current_user)
      end

      raise_define_structure_error unless @fae_navigation.respond_to? :structure

      @fae_topnav_items = @fae_navigation.items
      @fae_sidenav_items = @fae_navigation.side_nav(request.path)
    end

    # redirect to login after sign out
    def after_sign_out_path_for(resource_or_scope)
      fae.new_user_session_path
    end

    # redirect to requested page after sign in
    def after_sign_in_path_for(resource)
      request.env['omniauth.origin'] || stored_location_for(resource) || fae.root_path
    end

    def first_user_redirect
      redirect_to fae.first_user_path if Fae::User.live_super_admins.blank?
    end

    def set_change_user
      Fae::Change.current_user = current_user.id if current_user.present?
    end

    def raise_define_structure_error
      raise 'Fae::Navigation#structure is not defined, please define it in `app/models/concerns/fae/navigation_concern.rb`'
    end

    def all_models
      if Fae.use_cache
        Rails.cache.fetch('fae_all_models') do
          load_and_filter_models
        end
      else
        load_and_filter_models
      end
    end

    def load_and_filter_models
      # load of all models since Rails caches activerecord queries.
      Rails.application.eager_load!
      ActiveRecord::Base.descendants.map.reject { |m| m.name['Fae::'] || !m.instance_methods.include?(:fae_display_field) || Fae.dashboard_exclusions.include?(m.name) }
    end

  end
end
