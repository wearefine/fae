class RemoveFaviconableFromFaeImage < ActiveRecord::Migration
  def change
    remove_reference :fae_images, :faviconable, polymorphic: true, index: true
  end
end
