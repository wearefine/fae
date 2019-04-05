class CreateJerseys < ActiveRecord::Migration[4.2]
  def change
    create_table :jerseys do |t|
      t.string :name
      t.string :color

      t.timestamps null: false
    end
  end
end
