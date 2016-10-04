module Fae
  module Sortable
    extend ActiveSupport::Concern

    module ClassMethods

      def fae_sort(params)
        return all unless params.present? && params[:sort_by].present?

        attr_parts = params[:sort_by].split('.')

        if attr_parts.length == 1
          order_by_model_attr(attr_parts.first, sort_direction(params[:sort_direction]))
        else
          order_by_association_attr(attr_parts.first.to_sym, attr_parts.second, sort_direction(params[:sort_direction]))
        end
      end

      private

      def order_by_model_attr(sort_by, direction)
        return all unless attribute_exists(self, sort_by)
        unscope(:order).order("#{table_name}.#{sort_by} #{direction}")
      end

      def order_by_association_attr(association, sort_by, direction)
        assoc_index = reflect_on_all_associations.map(&:name).index(association)
        return all unless assoc_index
        order_klass = reflect_on_all_associations[assoc_index].klass

        return all unless attribute_exists(order_klass, sort_by)

        includes(association).unscope(:order).order("#{order_klass.table_name}.#{sort_by} #{direction}")
      end

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
