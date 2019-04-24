class AddAromaIdToCats < ActiveRecord::Migration[4.2]
  def change
    add_column :cats, :aroma_id, :integer
  end
end
