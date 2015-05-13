module Fae::Concerns::Models::Base
  require 'csv'
  extend ActiveSupport::Concern

  attr_accessor :filter

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
      binding.pry
      for_fae_index
    end

    def filter(params)
      binding.pry
      search = {}
      # detect all keys in the params object and append them to the search object.
      # get all params to use in the includes call
      # search['wines.slug'] = params[:wine] if params.present?

      unscoped
      .includes(:wine)
      .where(search)
    end

    def to_csv
      CSV.generate do |csv|
        csv << column_names
        all.each do |item|
          csv << item.attributes.values_at(*column_names)
        end
      end
    end

  end
end