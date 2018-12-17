class CreateCamdramTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :camdram_tokens do |t|
      t.string :token, null: false
      t.string :refresh_token, null: false
      t.boolean :expires, null: false
      t.integer :expires_at, null: false
      t.references :user, foreign_key: true, null: false

      t.timestamps
    end
  end
end
