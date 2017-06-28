class CreateReleaseNotes < ActiveRecord::Migration[4.2]
  def change
    create_table :release_notes do |t|
      t.string :title
      t.text :body
      t.integer :position

      t.timestamps null: false
    end
  end
end
