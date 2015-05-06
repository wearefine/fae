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
          item.position = ids.index(item.id.to_s) + 1
          item.save
        end
      end
      render nothing: true
    end

    private

    def can_toggle(klass)
      # restrict models that non-admins aren't allowed to update
      restricted_classes = %w(Fae::User Fae::Role Fae::Option)
      return false if restricted_classes.include?(klass.name.to_s) && !current_user.is_admin?
      true
    end

  end
end
