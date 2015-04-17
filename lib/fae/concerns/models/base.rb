module Fae::Concerns::Models::Base
  extend ActiveSupport::Concern

  module ClassMethods
    def for_fae_index
      order(order_method)
    end

    def order_method
      klass = name.constantize
      if klass.column_names.include? 'position'
        return :position
      elsif klass.column_names.include? 'name'
        return :name
      elsif klass.column_names.include? 'title'
        return :title
      else
        raise "No order_method found, please define for_fae_index as a #{name} class method to set a custom scope."
      end
    end

    def filter_all
    end

    def filter(params)
      search = {}
      search['wines.slug'] = params[:wine] if params[:wine].present?

      unscoped
      .includes(:wine)
      .where(search).order('wine.position')
      .active
    end

  end
end