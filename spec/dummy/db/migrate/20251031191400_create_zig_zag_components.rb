class CreateZigZagComponents < ActiveRecord::Migration[7.0]
  def change
    create_table :zig_zag_components do |t|
      t.string :name

      t.timestamps
    end
  end
end
