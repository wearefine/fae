module Fae
	class FormManager < ActiveRecord::Base

		include Fae::BaseModelConcern

	  def fae_display_field
	    model_name
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

	  end

	end
end