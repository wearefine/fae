module Fae
  module Sortable
    extend ActiveSupport::Concern

    module ClassMethods

      def fae_sort(params)
        return all unless params.present? && params[:sort_by].present?

        attr_parts = params[:sort_by].split('.')

        if attr_parts.length == 1
          order_table = table_name
          order_attr = attr_parts.first
        else
          assoc_sym = attr_parts.first.to_sym
          assoc_index = reflect_on_all_associations.map(&:name).index(assoc_sym)
          return all unless assoc_index
          order_klass = reflect_on_all_associations[assoc_index].klass
          order_table = order_klass.table_name
          order_attr = attr_parts.second
        end

        return all unless attribute_exists(order_klass || self, order_attr)

        includes(assoc_sym).unscope(:order).order("#{order_table}.#{order_attr} #{sort_direction(params[:sort_direction])}")
      end

      private

      def sort_direction(direction_from_params)
        return 'asc' if direction_from_params.blank?

        direction = direction_from_params.downcase
        # verify the direction from parms are legit to protect against injection
        return %w(asc desc).include?(direction) ? direction : 'asc'
      end

      def attribute_exists(klass, attribute)
        klass.column_names.include? attribute
      end

    end

  end
end
