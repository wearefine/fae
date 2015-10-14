class CreateWinemakers < ActiveRecord::Migration
  def change
    create_table :winemakers do |t|
      t.string :name
      t.integer :position
      t.references :wine, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
