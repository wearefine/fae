# This migration comes from fae (originally 20141120051309)
class AddRequiredToImagesAndFiles < ActiveRecord::Migration[4.2]
  def change
    add_column :fae_files, :required, :boolean, default: false
    add_column :fae_images, :required, :boolean, default: false
  end
end
