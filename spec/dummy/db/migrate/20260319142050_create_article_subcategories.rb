class CreateArticleSubcategories < ActiveRecord::Migration[7.0]
  def change
    create_table :article_subcategories do |t|
      t.string :name
      t.string :name_zh
      t.string :name_frca
      t.integer :article_category_id

      t.timestamps
    end
  end
end
