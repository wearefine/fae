class CreateFaeImagesTable < ActiveRecord::Migration[4.2]
  def change
    create_table(:fae_images) do |t|
      t.string :name
      t.string :asset
      t.references :imageable, polymorphic: true, index: true
      t.string :alt
      t.string :caption
      t.integer :position, default: 0
      t.string :attached_as, index: true
      t.boolean :on_stage, default: true
      t.boolean :on_prod, default: false
      t.integer :file_size
      t.boolean :required, default: false

      t.timestamps
    end
  end
end
