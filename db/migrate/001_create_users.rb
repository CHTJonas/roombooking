class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string  :name, null: false
      t.string  :email, null: false
      t.string  :provider, null: false
      t.string  :uid, null: false, index: true
      t.boolean :admin, default: false, null: false
      t.boolean :blocked, default: false, null: false

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
