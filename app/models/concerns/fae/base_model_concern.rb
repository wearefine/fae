module Fae
  module BaseModelConcern
    extend ActiveSupport::Concern
    # extend FAE::BaseSerializer
    require 'csv'

    attr_accessor :filter


    included do
      include Fae::Trackable if Fae.track_changes
      include Fae::Sortable
    end

    def fae_nested_parent
      # override this method in your model
    end

    def fae_tracker_parent
      # override this method in your model
    end

    def fae_nested_foreign_key
      return if fae_nested_parent.blank?
      "#{fae_nested_parent}_id"
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
        all.to_a.keep_if { |i| i.fae_display_field.present? && i.fae_display_field.to_s.downcase.include?(query.downcase) }
      end

      def to_csv
        CSV.generate do |csv|
          csv << column_names
          all.each do |item|
            csv << item.attributes.values_at(*column_names)
          end
        end
      end

      def translate(*attributes)
        attributes.each do |attribute|
          define_method attribute.to_s do
            self.send "#{attribute}_#{I18n.locale}"
          end

          define_singleton_method "find_by_#{attribute}" do |val|
            self.send("find_by_#{attribute}_#{I18n.locale}", val)
          end
        end
      end

    end
  end
end
