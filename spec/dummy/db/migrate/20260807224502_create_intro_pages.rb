class CreateIntroPages < ActiveRecord::Migration[7.0]
  def change
    create_table :intro_pages do |t|
      t.string :title
      t.text :body
      t.date :date
      t.references :article, type: :integer, foreign_key: true
      t.boolean :draft

      t.timestamps
    end
    add_index :intro_pages, :draft
  end
end
