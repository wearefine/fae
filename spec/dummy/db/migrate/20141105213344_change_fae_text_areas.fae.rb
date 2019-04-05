# This migration comes from fae (originally 20141105210119)
class ChangeFaeTextAreas < ActiveRecord::Migration[4.2]
  def change
    change_table :fae_text_areas do |t|
      t.remove :contentable
      t.column :contentable_id, :integer
      t.column :contentable_type, :string
      t.column :attached_as, :string
    end
    change_table :fae_pages do |t|
      t.column :slug, :string
    end

    add_index :fae_text_areas, :contentable_id
    add_index :fae_text_areas, :contentable_type
    add_index :fae_text_areas, :attached_as
    add_index :fae_text_areas, :position
    add_index :fae_text_areas, :on_stage
    add_index :fae_text_areas, :on_prod

    add_index :fae_pages, :slug
  end
end
