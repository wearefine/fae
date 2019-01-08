class CreateEventRelease < ActiveRecord::Migration[4.2]
  def change
    create_table :event_releases do |t|
      t.references :release, index: true
      t.references :event, index: true

      t.timestamps
    end
  end
end
