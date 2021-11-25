class AddUserToBatchImportResults < ActiveRecord::Migration[6.1]
  def change
    add_reference :batch_import_results, :user, null: true, foreign_key: true
  end
end
