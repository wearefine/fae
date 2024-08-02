module Fae
  class UtilitiesController < ApplicationController

    def toggle
      klass = params[:object].gsub('__', '/').classify
      if can_toggle(klass, params[:attr])
        klass = klass.constantize
        klass.find(params[:id]).toggle(params[:attr]).save(validate: false)
        # redirect back to referrer or the engine mount path
        redirect_back_or_to(Fae::Engine.routes.find_script_name({}), status: 303)
      else
        render body: nil, status: :unauthorized
      end
    end

    def sort
      if request.xhr?
        ids = params[params[:object]]
        klass = params[:object].gsub('fae_', 'fae/').gsub('__', '/').classify.constantize
        items = klass.find(ids)
        items.each do |item|
          position = ids.index(item.id.to_s) + 1
          item.update_attribute(:position, position)
        end
      end
      render body: nil
    end

    def language_preference
      if params[:language].present? && (params[:language] == 'all' || Fae.languages.has_key?(params[:language].to_sym))
        current_user.update_column(:language, params[:language])
      end
      render body: nil
    end

    def global_search
      if params[:query].present? && params[:query].length > 2
        search_locals = { navigation_items: @fae_navigation.search(params[:query]), records: records_by_display_name(params[:query]) }
      else
        search_locals = { show_nav: true }
      end
      render partial: 'global_search_results', locals: search_locals
    end

    private

    def can_toggle(klass, attribute)
      # check if class exists and convert
      return false unless Object.const_defined?(klass)
      klass = klass.constantize

      # allow admins to toggle Fae::User#active
      return true if klass == Fae::User && attribute == 'active' && current_user.super_admin_or_admin?

      # restrict models that only super admins can toggle
      restricted_classes = %w(Fae::User Fae::Role Fae::Option Fae::Change)
      return false if restricted_classes.include?(klass.name.to_s) && !current_user.super_admin?

      # restrict to only other boolean fields
      return false unless klass.columns_hash[attribute].type == :boolean

      true
    end

    def records_by_display_name(query)
      records = []
      all_models.each do |m|
        records += m.fae_search(query) if m.respond_to?(:fae_search)
      end
      records
    end

  end
end
