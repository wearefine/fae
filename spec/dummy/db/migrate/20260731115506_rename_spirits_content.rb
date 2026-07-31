class RenameSpiritsContent < ActiveRecord::Migration[7.0]
  def change
    rename_column :spirits, :content, :description
  end
end
