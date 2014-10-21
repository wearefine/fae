class AddVideoToRelease < ActiveRecord::Migration
  def change
    add_column :releases, :video_url, :string
  end
end
