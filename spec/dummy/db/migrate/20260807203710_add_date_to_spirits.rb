class AddDateToSpirits < ActiveRecord::Migration[7.0]
  def change
    add_column :spirits, :date, :date
  end
end
