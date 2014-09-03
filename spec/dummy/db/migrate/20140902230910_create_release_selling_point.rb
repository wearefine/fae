class CreateReleaseSellingPoint < ActiveRecord::Migration
  def change
    create_table :release_selling_points do |t|
      t.references :release
      t.references :selling_point
      t.integer :position

      t.timestamps
    end
  end
end
