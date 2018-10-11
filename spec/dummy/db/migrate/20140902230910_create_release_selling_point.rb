class CreateReleaseSellingPoint < ActiveRecord::Migration[4.2]
  def change
    create_table :release_selling_points do |t|
      t.references :release
      t.references :selling_point
      t.integer :position

      t.timestamps
    end
  end
end
