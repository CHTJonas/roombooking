class CreateBatchImportResults < ActiveRecord::Migration[6.1]
  def change
    create_table :batch_import_results, id: false do |t|
      t.string :jid, null: false
      t.timestamp :queued, null: false
      t.timestamp :started
      t.timestamp :completed
      t.integer :shows_imported_successfully, array: true
      t.integer :shows_imported_unsuccessfully, array: true
      t.integer :shows_already_imported, array: true
    end
    add_index :batch_import_results, :jid, unique: true
  end
end
