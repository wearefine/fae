# This migration comes from fae (originally 20141009001324)
class AddHasMobileAndTabletToFaeImages < ActiveRecord::Migration
  def change
    add_column :fae_images, :has_mobile, :boolean, default: false
    add_column :fae_images, :has_tablet, :boolean, default: false
  end
end
