# This migration comes from fae (originally 20150513170213)
class AddLanguageToUsers < ActiveRecord::Migration
  def change
    add_column :fae_users, :language, :string
  end
end
