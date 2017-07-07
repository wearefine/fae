module Fae
  class UtilitiesController < ApplicationController
    def toggle
      klass = params[:object].gsub('__', '/').classify.constantize
      if can_toggle(klass)
        klass.find(params[:id]).toggle(params[:attr]).save(validate: false)
        render body: nil
      else
        render body: nil, status: :unauthorized
      end
    end

    def sort_tree
      if request.xhr?

        # the parameters are in this format
        # params: {
        #  data: {
        #    item: 'news_article_24',
        #    parent: 'news_article_3'
        #  }
        # }

        # the regex matches the model's name and the id
        model_name_and_id_re = /(.+)_(\d+)/

        model, id = params[:data][:item]
                    .match(model_name_and_id_re).values_at(1, 2)

        _, parent_id = params[:data][:parent]
                       .match(model_name_and_id_re).try(:values_at, 1, 2)

        klass = model.classify.constantize
        record = klass.find(id)
        record.update_attribute(:parent_id, parent_id)
        if params[:data][:sort_order].present?
          record.insert_at(params[:data][:sort_order].to_i)
        end
      end
      render body: nil
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

    def can_toggle(klass)
      # restrict models that non-admins aren't allowed to update
      restricted_classes = %w(Fae::User Fae::Role Fae::Option)
      return false if restricted_classes.include?(klass.name.to_s) && !current_user.super_admin_or_admin?
      true
    end

    def records_by_display_name(query)
      records = []
      all_models.each do |m|
        records += m.fae_search(query)
      end
      records
    end
  end
end
