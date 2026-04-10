class CreateBeerAromas < ActiveRecord::Migration[6.1]
  def change
    create_table :beer_aromas do |t|
      t.integer :beer_id, index: true
      t.integer :aroma_id, index: true
      t.integer :position, index: true

      t.timestamps
    end
  end
end
