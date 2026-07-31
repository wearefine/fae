class AddContentToSpirits < ActiveRecord::Migration[7.0]
  def change
    add_column :spirits, :content, :text
  end
end
