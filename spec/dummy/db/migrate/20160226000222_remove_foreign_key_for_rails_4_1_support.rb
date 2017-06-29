class RemoveForeignKeyForRails41Support < ActiveRecord::Migration[4.2]
  def change
    remove_foreign_key :winemakers, :wines
  end
end
