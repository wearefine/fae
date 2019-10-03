class RenameFormManagersModelName < ActiveRecord::Migration[5.2]
  def change
  	rename_column :fae_form_managers, :model_name, :form_manager_model_name
  end
end
