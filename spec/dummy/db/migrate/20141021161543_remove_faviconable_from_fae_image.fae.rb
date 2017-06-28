# This migration comes from fae (originally 20141021161414)
class RemoveFaviconableFromFaeImage < ActiveRecord::Migration[4.2]
  def change
    remove_reference :fae_images, :faviconable, polymorphic: true, index: true
  end
end
