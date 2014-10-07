module Fae::Concerns::Models::Base
  extend ActiveSupport::Concern

  def includes
    before_save start_date = DateTime.parse(start_date)
    before_save end_date = DateTime.parse(end_date)
  end

  def display_name
    name
  end

  module ClassMethods
    def for_admin_index
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
        raise "No order_method found, please define for_admin_index as a #{name} class method to set a custom order."
      end
    end

  end
end