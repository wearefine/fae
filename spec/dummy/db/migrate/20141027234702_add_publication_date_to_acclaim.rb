class AddPublicationDateToAcclaim < ActiveRecord::Migration
  def change
    add_column :acclaims, :publication_date, :date
  end
end
