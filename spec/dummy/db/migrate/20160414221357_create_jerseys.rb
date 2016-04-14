class CreateJerseys < ActiveRecord::Migration
  def change
    create_table :jerseys do |t|
      t.string :name
      t.string :color

      t.timestamps null: false
    end
  end
end
