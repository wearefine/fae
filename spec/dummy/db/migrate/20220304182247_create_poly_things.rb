class CreatePolyThings < ActiveRecord::Migration[5.2]
  def change
    create_table :poly_things do |t|
      t.string :name
      t.references :poly_thingable, polymorphic: true

      t.timestamps
    end
  end
end
