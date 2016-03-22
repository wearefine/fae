module Fae
  class UtilitiesController < ApplicationController

    def toggle
      klass = params[:object].gsub('fae_', 'fae/').classify.constantize
      if can_toggle(klass)
        klass.find(params[:id]).toggle(params[:attr]).save(validate: false)
        render nothing: true
      else
        render nothing: true, status: :unauthorized
      end
    end

    def sort
      if request.xhr?
        ids = params[params[:object]]
        params[:object].gsub!('fae_', 'fae/')
        klass = params[:object].classify.constantize
        items = klass.find(ids)
        items.each do |item|
          position = ids.index(item.id.to_s) + 1
          item.update_attribute(:position, position)
        end
      end
      render nothing: true
    end

    def language_preference
      if params[:language].present? && (params[:language] == 'all' || Fae.languages.has_key?(params[:language].to_sym))
        current_user.update_column(:language, params[:language])
      end
      render nothing: true
    end

    private

    def can_toggle(klass)
      # restrict models that non-admins aren't allowed to update
      restricted_classes = %w(Fae::User Fae::Role Fae::Option)
      return false if restricted_classes.include?(klass.name.to_s) && !current_user.super_admin_or_admin?
      true
    end

  end
end
