class AddFileSizeToFaeImages < ActiveRecord::Migration
  def change
    add_column :fae_images, :file_size, :integer
  end
end
