class CreateCats < ActiveRecord::Migration[4.2]
  def change
    create_table :cats do |t|
      t.string :name
      t.boolean :friendly
      t.text :description

      t.timestamps null: false
    end
  end
end
