class CreateFaeVideos < ActiveRecord::Migration[5.2]
  def change
    create_table :fae_videos do |t|
      t.string :upload_id, index: true
      t.string :asset_id, index: true
      t.string :playback_id
      t.string :title
      t.string :status
      t.float :duration
      t.string :aspect_ratio
      t.references :videoable, polymorphic: true, index: true
      t.string :attached_as, index: true
      t.boolean :required, default: false

      t.timestamps
    end
  end
end
