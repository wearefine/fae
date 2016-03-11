class AddAromaIdToCats < ActiveRecord::Migration
  def change
    add_column :cats, :aroma_id, :integer
  end
end
