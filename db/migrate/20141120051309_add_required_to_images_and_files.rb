class AddRequiredToImagesAndFiles < ActiveRecord::Migration
  def change
    add_column :fae_files, :required, :boolean, default: false
    add_column :fae_images, :required, :boolean, default: false
  end
end
