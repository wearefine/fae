class AddLanguageFieldsToPolyThing < ActiveRecord::Migration[7.0]
  def change
    add_column :poly_things, :name_frca, :string
    rename_column :poly_things, :name, :name_en
  end
end
