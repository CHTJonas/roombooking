class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string  :name, null: false
      t.string  :email, null: false
      t.boolean :admin, default: false, null: false
      t.boolean :sysadmin, default: false, null: false
      t.boolean :blocked, default: false, null: false
      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :admin, where: 'admin = true'
  end
end
