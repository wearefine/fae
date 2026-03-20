class AddLanguageFieldsToTextComponents < ActiveRecord::Migration[7.0]
  def change
    add_column :text_components, :name_zh, :string
    add_column :text_components, :name_frca, :string
  end
end
