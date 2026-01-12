class CreateListItems < ActiveRecord::Migration[7.0]
  def change
    create_table :list_items do |t|
      t.string :name
      t.string :people
      t.boolean :on_stage
      t.boolean :on_prod
      t.integer :position
      t.integer :static_page_id

      t.timestamps
    end
  end
end
