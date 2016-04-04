module Fae
  module BaseModelConcern
    extend ActiveSupport::Concern
    require 'csv'

    attr_accessor :filter

    included do
      include Fae::Trackable if Fae.track_changes
    end

    module ClassMethods
      def fae_display_field
        # override this method in your model
      end

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
        # override this method in your model
        for_fae_index
      end

      def filter(params)
        # override this method in your model
        for_fae_index
      end

      def fae_search(query)
        all.to_a.keep_if { |i| i.fae_display_field.present? && i.fae_display_field.downcase.include?(query.downcase) }
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
end
