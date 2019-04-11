class ChangeTokensToEncryptedTokens < ActiveRecord::Migration[5.2]
  def up
    rename_column :camdram_tokens, :access_token, :temp_access_token
    rename_column :camdram_tokens, :refresh_token, :temp_refresh_token
    add_column    :camdram_tokens, :encrypted_access_token, :binary
    add_column    :camdram_tokens, :encrypted_access_token_iv, :binary
    add_column    :camdram_tokens, :encrypted_refresh_token, :binary
    add_column    :camdram_tokens, :encrypted_refresh_token_iv, :binary
    add_index     :camdram_tokens, :encrypted_access_token_iv, unique: true
    add_index     :camdram_tokens, :encrypted_refresh_token_iv, unique: true
    CamdramToken.find_each(batch_size: 10) do |token|
      token.access_token = token.temp_access_token
      token.refresh_token = token.temp_refresh_token
      token.save!
    end
    remove_column :camdram_tokens, :temp_access_token
    remove_column :camdram_tokens, :temp_refresh_token
    change_column_null :camdram_tokens, :encrypted_access_token, false
    change_column_null :camdram_tokens, :encrypted_access_token_iv, false
    change_column_null :camdram_tokens, :encrypted_refresh_token, false
    change_column_null :camdram_tokens, :encrypted_refresh_token_iv, false
  end
  def down
    add_column    :camdram_tokens, :temp_access_token, :string
    add_column    :camdram_tokens, :temp_refresh_token, :string
    add_index :camdram_tokens, :temp_access_token, unique: true
    add_index :camdram_tokens, :temp_refresh_token, unique: true
    CamdramToken.find_each(batch_size: 10) do |token|
      token.temp_access_token = token.access_token
      token.temp_refresh_token = token.refresh_token
      token.save!
    end
    remove_column :camdram_tokens, :encrypted_access_token
    remove_column :camdram_tokens, :encrypted_access_token_iv
    remove_column :camdram_tokens, :encrypted_refresh_token
    remove_column :camdram_tokens, :encrypted_refresh_token_iv
    rename_column :camdram_tokens, :temp_access_token, :access_token
    rename_column :camdram_tokens, :temp_refresh_token, :refresh_token
    change_column_null :camdram_tokens, :access_token, false
    change_column_null :camdram_tokens, :refresh_token, false
  end
end
