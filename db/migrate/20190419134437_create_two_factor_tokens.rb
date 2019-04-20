class CreateTwoFactorTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :two_factor_tokens do |t|
      t.binary :encrypted_secret
      t.binary :encrypted_secret_iv
      t.references :user, foreign_key: true, null: false
      t.timestamps
    end
  end
end
