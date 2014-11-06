class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :name
      t.references :contact, index: true

      t.timestamps
    end
  end
end
