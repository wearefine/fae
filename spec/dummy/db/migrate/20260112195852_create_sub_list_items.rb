class CreateSubListItems < ActiveRecord::Migration[7.0]
  def change
    create_table :sub_list_items do |t|
      t.string :name
      t.text :body
      t.boolean :on_stage
      t.boolean :on_prod
      t.integer :position
      t.integer :list_item_id

      t.timestamps
    end
  end
end
