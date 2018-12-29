class CreateVersions < ActiveRecord::Migration[5.2]
  def change
    create_table :versions do |t|
      t.string :item_type, null: false, index: true
      t.string :item_subtype, null: true
      t.integer :item_id, null: false, index: true
      t.string :event, null: false
      t.string :whodunnit
      t.json :object
      t.json :object_changes
      t.string :ip  # could change to :inet but would lose support for SQLite
      t.string :user_agent
      t.datetime :created_at
    end
  end
end
