class CreateArticleCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :article_categories do |t|
      t.string :name
      t.integer :position

      t.timestamps
    end
  end
end
