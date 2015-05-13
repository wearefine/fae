class AddLanguageToUsers < ActiveRecord::Migration
  def change
    add_column :fae_users, :language, :string
  end
end
