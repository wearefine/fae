class CreateCars < ActiveRecord::Migration[7.0]
  def change
    create_table :cars do |t|
      t.string :name_en
      t.string :name_frca
      t.string :name_zh
      t.boolean :draft

      t.timestamps
    end
    add_index :cars, :draft
  end
end
