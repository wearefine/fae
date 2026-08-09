class CreateCarCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :car_categories do |t|
      t.string :name
      t.string :slug
      t.integer :position
      t.boolean :on_stage
      t.boolean :on_prod
      t.boolean :draft

      t.timestamps
    end
    add_index :car_categories, :draft
  end
end
