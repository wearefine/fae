class CreateWineBeers < ActiveRecord::Migration[7.0]
  def change
    create_table :wine_beers do |t|
      t.integer :wine_id
      t.integer :beer_id

      t.timestamps
    end
  end
end
