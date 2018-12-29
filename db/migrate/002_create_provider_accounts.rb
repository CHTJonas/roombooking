class CreateProviderAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :provider_accounts do |t|
      t.string  :provider, null: false
      t.string  :uid, null: false, index: true
      t.references :user, foreign_key: true, null: false
      t.timestamps
    end
    add_index :provider_accounts, [:provider, :uid], unique: true
  end
end
