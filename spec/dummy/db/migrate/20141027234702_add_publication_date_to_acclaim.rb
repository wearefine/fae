class AddPublicationDateToAcclaim < ActiveRecord::Migration[4.2]
  def change
    add_column :acclaims, :publication_date, :date
  end
end
