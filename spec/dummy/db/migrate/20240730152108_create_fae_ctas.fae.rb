# This migration comes from fae (originally 20240730152108)
class CreateFaeCtas < ActiveRecord::Migration[7.0]
  def change
    create_table :fae_ctas do |t|
      t.string :cta_label
      t.text :cta_link
      t.string :cta_alt_text
      t.references :ctaable, polymorphic: true, index: true
      t.string :attached_as, index: true

      t.timestamps
    end
  end
end
