class CreateCats < ActiveRecord::Migration
  def change
    create_table :cats do |t|
      t.boolean :tail
      t.string :whiskers
      t.text :body

      t.timestamps null: false
    end
  end
end
