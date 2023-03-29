class CreateSubAromas < ActiveRecord::Migration[7.0]
  def change
    create_table :sub_aromas do |t|
      t.string :name, index: true
      t.integer :aroma_id, index: true

      t.timestamps
    end
  end
end
