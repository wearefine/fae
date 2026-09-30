# This migration comes from fae (originally 20260925180000)
class AddAltToFaeVideos < ActiveRecord::Migration[5.2]
  def change
    add_column :fae_videos, :alt, :string
  end
end
