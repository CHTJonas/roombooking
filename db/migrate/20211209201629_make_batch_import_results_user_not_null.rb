class MakeBatchImportResultsUserNotNull < ActiveRecord::Migration[6.1]
  def change
    change_column_null :batch_import_results, :user_id, false
  end
end
