class CreateStaticPageAromas < ActiveRecord::Migration[7.0]
  def change
    create_table :static_page_aromas do |t|
      t.integer :static_page_id, index: true
      t.integer :aroma_id, index: true
      t.integer :position, index: true

      t.timestamps
    end
  end
end
