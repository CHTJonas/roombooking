class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string  :name
      t.string  :email
      t.string  :provider
      t.string  :uid
      t.boolean :admin

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
