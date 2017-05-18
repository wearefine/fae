class CreateMilestones < ActiveRecord::Migration[4.2]
  def change
    create_table :milestones do |t|
      t.integer :year
      t.string :description

      t.timestamps null: false
    end
  end
end
