class AddVideoToRelease < ActiveRecord::Migration[4.2]
  def change
    add_column :releases, :video_url, :string
  end
end
