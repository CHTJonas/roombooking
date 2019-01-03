class CreateCamdramTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :camdram_tokens do |t|
      t.string :access_token, null: false
      t.string :refresh_token, null: false
      t.integer :expires_at, null: false
      t.references :user, foreign_key: true, null: false
      t.timestamps
    end
    add_index :camdram_tokens, :access_token, unique: true
    add_index :camdram_tokens, :refresh_token, unique: true
    add_index :camdram_tokens, :created_at, order: { created_at: :desc }
  end
end
