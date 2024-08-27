class CreateAuthors < ActiveRecord::Migration[7.0]
  def change
    create_table :authors do |t|
      t.string :name_en
      t.string :name_zh
      t.string :name_frca
      t.integer :article_id

      t.timestamps
    end
  end
end
