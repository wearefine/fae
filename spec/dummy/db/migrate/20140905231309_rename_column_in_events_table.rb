class RenameColumnInEventsTable < ActiveRecord::Migration
  def change
    rename_column :events, :people_id, :person_id
  end
end
