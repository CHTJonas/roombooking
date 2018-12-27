class CreateVersionAssociations < ActiveRecord::Migration[5.2]
  def change
    create_table :version_associations do |t|
      t.integer :version_id, index: true
      t.string :foreign_key_name, null: false
      t.integer :foreign_key_id
      t.integer :transaction_id, index: true
    end
    add_index :version_associations,
      %i(foreign_key_name foreign_key_id),
      name: "index_version_associations_on_foreign_key"
  end
end
