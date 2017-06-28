class AddContentToReleases < ActiveRecord::Migration[4.2][5.0]
  def change
    add_column :releases, :content, :text
  end
end
