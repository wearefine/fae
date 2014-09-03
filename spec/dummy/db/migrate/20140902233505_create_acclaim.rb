class CreateAcclaim < ActiveRecord::Migration
  def change
    create_table :acclaims do |t|
      t.string :score
      t.string :publication
      t.text :description

      t.boolean :on_stage, default: true
      t.boolean :on_prod, default: false
      t.integer :position

      t.integer :release_id
      t.timestamps
    end
  end
end
