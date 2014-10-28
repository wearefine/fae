# This migration comes from fae (originally 20141021181327)
class CreateFaeFiles < ActiveRecord::Migration
  def change
    create_table :fae_files do |t|
      t.string :name
      t.string :asset
      t.references :fileable, polymorphic: true, index: true
      t.integer :file_size
      t.integer :position, default: 0
      t.string :attached_as, index: true
      t.boolean :on_stage, default: true
      t.boolean :on_prod, default: false

      t.timestamps
    end
  end
end
