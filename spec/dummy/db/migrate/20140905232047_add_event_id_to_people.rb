class AddEventIdToPeople < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :event_id, :integer
  end
end
