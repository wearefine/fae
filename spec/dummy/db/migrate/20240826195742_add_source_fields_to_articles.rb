class AddSourceFieldsToArticles < ActiveRecord::Migration[7.0]
  def change
    add_column :articles, :source_en, :string
    add_column :articles, :source_zh, :string
    add_column :articles, :source_frca, :string
  end
end
