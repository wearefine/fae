class CreateTrucks < ActiveRecord::Migration[7.0]
  def change
    create_table :trucks do |t|
      t.string :name
      t.string :slug
      t.boolean :draft

      t.timestamps
    end
    add_index :trucks, :draft
  end
end
