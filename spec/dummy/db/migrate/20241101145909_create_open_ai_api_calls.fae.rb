class CreateOpenAiApiCalls < ActiveRecord::Migration[7.0]
  def change
    create_table :fae_open_ai_api_calls do |t|
      t.string :call_type, index: true
      t.integer :tokens, index: true

      t.timestamps
    end
  end
end
