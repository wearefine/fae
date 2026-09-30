class AddAltToFaeVideos < ActiveRecord::Migration[5.2]
  def change
    add_column :fae_videos, :alt, :string
  end
end
