class AddCustomisationsToVersions < ActiveRecord::Migration[6.0]
  def change
    add_column :versions, :item_subtype, :string, null: true
    add_column :versions, :object, :jsonb
    add_column :versions, :object_changes, :jsonb
    add_column :versions, :ip, :inet
    add_column :versions, :user_agent, :string
    add_column :versions, :session, :bigint
  end
end
