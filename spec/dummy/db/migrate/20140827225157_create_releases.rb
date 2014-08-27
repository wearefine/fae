class CreateReleases < ActiveRecord::Migration
  def change
    create_table :releases do |t|
      t.string :name
      t.string :slug
      t.text :intro
      t.text :body
      t.string :vintage
      t.string :price
      t.string :tasting_notes_pdf
      t.integer :wine_id
      t.integer :varietal_id
      t.boolean :on_stage, default: true
      t.boolean :on_prod, default: false
      t.integer :position

      t.timestamps
    end
  end
end
