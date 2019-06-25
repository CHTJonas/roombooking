class CreateCamdramTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :camdram_tokens do |t|
      t.binary :encrypted_access_token, null: false
      t.binary :encrypted_access_token_iv, null: false
      t.binary :encrypted_refresh_token, null: false
      t.binary :encrypted_refresh_token_iv, null: false
      t.datetime :expires_at, null: false
      t.references :user, foreign_key: true, null: false
      t.timestamps
    end
    add_index :camdram_tokens, :encrypted_access_token_iv, unique: true
    add_index :camdram_tokens, :encrypted_refresh_token_iv, unique: true
    add_index :camdram_tokens, :created_at, order: { created_at: :desc }
  end
end
