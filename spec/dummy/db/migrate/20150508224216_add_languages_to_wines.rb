class AddLanguagesToWines < ActiveRecord::Migration[4.2]
  def change
    rename_column :wines, :name, :name_en
    add_column :wines, :name_zh, :string
    add_column :wines, :name_ja, :string
    add_column :wines, :description_en, :text
    add_column :wines, :description_zh, :text
    add_column :wines, :description_ja, :text
    add_column :wines, :food_pairing_en, :text
    add_column :wines, :food_pairing_zh, :text
    add_column :wines, :food_pairing_ja, :text
  end
end
