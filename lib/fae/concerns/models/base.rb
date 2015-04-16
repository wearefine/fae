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