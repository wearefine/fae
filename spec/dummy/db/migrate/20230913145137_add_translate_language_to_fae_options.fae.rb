# This migration comes from fae (originally 20230913144458)
class AddTranslateLanguageToFaeOptions < ActiveRecord::Migration[7.0]
  def change
    add_column :fae_options, :translate_language, :boolean
  end
end
