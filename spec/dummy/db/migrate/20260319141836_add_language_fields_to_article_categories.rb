class AddLanguageFieldsToArticleCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :article_categories, :name_zh, :string
    add_column :article_categories, :name_frca, :string
  end
end
