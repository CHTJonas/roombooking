class CreateVersionAssociations < ActiveRecord::Migration[5.2]
  def change
    create_table :version_associations do |t|
      t.integer :version_id
      t.string :foreign_key_name, null: false
      t.integer :foreign_key_id
      t.string :foreign_type
      t.integer :transaction_id
    end
    add_index :version_associations, :version_id
    add_index :version_associations,
      [:foreign_key_name, :foreign_key_id, :foreign_type], name: 'index_version_associations_on_foreign_key'
  end
end
