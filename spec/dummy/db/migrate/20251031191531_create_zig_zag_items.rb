class CreateZigZagItems < ActiveRecord::Migration[7.0]
  def change
    create_table :zig_zag_items do |t|
      t.string :heading
      t.text :body
      t.integer :position, index: true
      t.boolean :on_stage, index: true, default: true
      t.boolean :on_prod, index: true, default: false
      t.integer :zig_zag_component_id, index: true

      t.timestamps
    end
  end
end
