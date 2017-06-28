class RenameColumnInEventsTable < ActiveRecord::Migration[4.2]
  def change
    rename_column :events, :people_id, :person_id
  end
end
