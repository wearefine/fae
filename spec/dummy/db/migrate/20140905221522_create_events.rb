class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.date :start_date
      t.date :end_date
      t.string :event_type
      t.string :city

      t.integer :people_id

      t.timestamps
    end
  end
end
