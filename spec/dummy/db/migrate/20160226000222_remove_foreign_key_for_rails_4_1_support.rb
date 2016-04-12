class RemoveForeignKeyForRails41Support < ActiveRecord::Migration
  def change
    remove_foreign_key :winemakers, :wines
  end
end
