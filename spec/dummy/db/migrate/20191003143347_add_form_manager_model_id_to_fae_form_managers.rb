class AddFormManagerModelIdToFaeFormManagers < ActiveRecord::Migration[5.2]
  def change
  	add_column :fae_form_managers, :form_manager_model_id, :integer
  end
end
