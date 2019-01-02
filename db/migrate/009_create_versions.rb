class CreateVersions < ActiveRecord::Migration[5.2]
  def change
    create_table :versions do |t|
      t.string :item_type, null: false
      t.string :item_subtype, null: true
      t.integer :item_id, null: false
      t.string :event, null: false
      t.string :whodunnit
      t.jsonb :object
      t.jsonb :object_changes
      t.integer :transaction_id
      t.inet :ip
      t.string :user_agent
      t.datetime :created_at
    end
    add_index :versions, [:item_type, :item_id]
    add_index :versions, :transaction_id
  end
end
