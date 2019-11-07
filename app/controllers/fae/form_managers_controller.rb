module Fae
  class FormManagersController < ApplicationController

    def update
      if params[:form_manager].present?
        fields_serialized = params[:form_manager][:fields].to_json
        conditions = {
          form_manager_model_name: params[:form_manager][:form_manager_model_name],
        }
        if params[:form_manager][:form_manager_model_name] == 'Fae::StaticPage'
          conditions[:form_manager_model_id] = params[:form_manager][:form_manager_model_id]
        end
        FormManager.where(conditions).first_or_initialize.update_attribute(:fields, fields_serialized)
      end
      render body: nil
    end

  end
end
