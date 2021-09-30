class RemoveAdminOnlyFromRooms < ActiveRecord::Migration[6.1]
  def change
    remove_column :rooms, :admin_only
  end
end
