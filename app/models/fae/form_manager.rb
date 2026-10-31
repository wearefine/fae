module Fae
	class FormManager < ActiveRecord::Base

		include Fae::BaseModelConcern

	  def fae_display_field
	    model_name
	  end

	  def field_settings
	    parsed = fields.present? ? JSON.parse(fields) : {}
	    parsed.is_a?(Hash) ? parsed : {}
	  rescue JSON::ParserError
	    {}
	  end

	  def max_length_for(field_id)
	    settings = field_settings[field_id]
	    return unless settings.is_a?(Hash)

	    value = settings['maxLength'].to_s.strip
	    value.to_i if value.match?(/\A\d+\z/) && value.to_i.positive?
	  end

	  class << self

	    def for_model(params, item)
				if item.present? && item.class.superclass.name == 'Fae::StaticPage'
					conditions = {form_manager_model_name: 'Fae::StaticPage', form_manager_model_id: item.fae_form_manager_model_id}
				else
					conditions = {form_manager_model_name: params[:controller].gsub('admin/','').classify}
				end
	      where(conditions).first
	    end

	    # Matches the data-form-manager-id set on form field wrappers
	    def field_id_for(record, attribute)
	      "#{record.try(:attached_as).presence || record.class.name}_#{attribute}"
	    end

	    # Form Manager max length override for a record's attribute, capped by the column's limit when the database reports one
	    def max_length_override(record, attribute)
	      return unless Fae.use_form_manager && table_exists?

	      conditions, field_id = lookup_for_record(record, attribute)
	      return if conditions.blank?

	      max_length = where(conditions).first.try(:max_length_for, field_id)
	      return if max_length.blank?

	      [max_length, column_limit(record, attribute)].compact.min
	    end

	    private

	    def lookup_for_record(record, attribute)
	      if content_block?(record)
	        page = record.contentable
	        page_class = "#{page.slug}_page".classify.safe_constantize
	        return if page_class.blank?

	        [{ form_manager_model_name: 'Fae::StaticPage', form_manager_model_id: page.id }, "#{page_class.name}_#{record.attached_as}"]
	      elsif record.respond_to?(:fae_form_manager_model_name) && record.try(:attached_as).blank?
	        conditions = { form_manager_model_name: record.fae_form_manager_model_name }
	        conditions[:form_manager_model_id] = record.fae_form_manager_model_id if conditions[:form_manager_model_name] == 'Fae::StaticPage'
	        [conditions, field_id_for(record, attribute)]
	      end
	    end

	    def content_block?(record)
	      record.try(:attached_as).present? && record.try(:contentable).is_a?(Fae::StaticPage)
	    end

	    def column_limit(record, attribute)
	      column = record.class.try(:columns_hash).try(:[], attribute.to_s)
	      column.limit if column.present? && [:string, :text].include?(column.type)
	    end

	  end

	end
end