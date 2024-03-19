module Fae
  module BaseModelConcern
    extend ActiveSupport::Concern
    require 'csv'
    require 'slack-notifier'

    attr_accessor :filter

    included do
      include Fae::Trackable if Fae.track_changes
      include Fae::Sortable
      after_create :notify_initiation
      before_save :notify_changes
    end

    def notify_changes
      return unless notifiable_attributes.present?
      notifiable_attributes.each do |field_name_symbol|
        if self.send("#{field_name_symbol}_changed?") && self.send(field_name_symbol).present?
          send_slack(field_name_symbol)
        end
      end
    end

    def notify_initiation
      return unless notifiable_attributes.present?
      notifiable_attributes.each do |field_name_symbol|
        if self.send(field_name_symbol).present?
          send_slack(field_name_symbol)
        end
      end
    end

    def notifiable_attributes
      # override this method in your model
      # array of attributes to notify if changed
    end

    def fae_display_field
      # override this method in your model
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

    def fae_form_manager_model_name
      return 'Fae::StaticPage' if self.class.name.constantize.superclass.name == 'Fae::StaticPage'
      self.class.name
    end

    def fae_form_manager_model_id
      self.id
    end

    def send_slack(field_name_symbol)
      notifier = Slack::Notifier.new ENV["SLACK_WEBHOOK_URL"]
      notifier.ping "#{Rails.application.class.module_parent_name} - #{name} (#{self.class.name.constantize}) - #{field_name_symbol.to_s} set to '#{self.send(field_name_symbol)}'"

    end

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

      def fae_translate(*attributes)
        attributes.each do |attribute|
          define_method attribute.to_s do
            if self.try("#{attribute}_#{I18n.locale}").present?
              self.send "#{attribute}_#{I18n.locale}"
            else
              self.send "#{attribute}_en"
            end
          end

          define_singleton_method "find_by_#{attribute}" do |val|
            if self.has_attribute?("#{attribute}_#{I18n.locale}")
              self.send("find_by_#{attribute}_#{I18n.locale}", val)
            else
              self.send("find_by_#{attribute}_en", val)
            end
          end
        end
      end

      def fae_image_translate(*attributes)
        attributes.each do |attribute|
          define_method attribute.to_s do
            if self.respond_to?("#{attribute}_#{I18n.locale}") && asset_and_url_present?(self.send("#{attribute}_#{I18n.locale}"))
              self.send "#{attribute}_#{I18n.locale}"
            else
              self.send "#{attribute}_en"
            end
          end

          define_singleton_method "find_by_#{attribute}" do |val|
            if self.has_attribute?("#{attribute}_#{I18n.locale}")
              self.send("find_by_#{attribute}_#{I18n.locale}", val)
            else
              self.send("find_by_#{attribute}_en", val)
            end
          end
        end
      end

      def fae_file_translate(*attributes)
        attributes.each do |attribute|
          define_method attribute.to_s do
            if self.respond_to?("#{attribute}_#{I18n.locale}") && asset_and_url_present?(self.send("#{attribute}_#{I18n.locale}"))
              self.send "#{attribute}_#{I18n.locale}"
            else
              self.send "#{attribute}_en"
            end
          end

          define_singleton_method "find_by_#{attribute}" do |val|
            if self.has_attribute?("#{attribute}_#{I18n.locale}")
              self.send("find_by_#{attribute}_#{I18n.locale}", val)
            else
              self.send("find_by_#{attribute}_en", val)
            end
          end
        end
      end

      def has_fae_image(image_name_symbol)
        has_one image_name_symbol, -> { where(attached_as: image_name_symbol.to_s) },
          as: :imageable,
          class_name: '::Fae::Image',
          dependent: :destroy
        accepts_nested_attributes_for image_name_symbol, allow_destroy: true
      end

      def has_fae_file(file_name_symbol)
        has_one file_name_symbol, -> { where(attached_as: file_name_symbol.to_s) },
          as: :fileable,
          class_name: '::Fae::File',
          dependent: :destroy
        accepts_nested_attributes_for file_name_symbol, allow_destroy: true
      end

      def has_fae_seo_set(set_name_symbol)
        has_one set_name_symbol,
          as: :seo_setable,
          class_name: '::Fae::SeoSet',
          dependent: :destroy
        accepts_nested_attributes_for set_name_symbol, allow_destroy: true
      end

    end

    private

    def asset_and_url_present?(obj)
      obj.asset.present? && obj.asset.url.present?
    end

    def fae_bust_navigation_caches
      Fae::Role.all.each do |role|
        Rails.cache.delete("fae_navigation_#{role.id}")
      end
    end

  end
end
