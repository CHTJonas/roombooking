class CreateCamdramTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :camdram_tokens do |t|
      t.string :token
      t.string :refresh_token
      t.boolean :expires
      t.integer :expires_at
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
