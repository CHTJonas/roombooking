class AddAdminOnlyToRooms < ActiveRecord::Migration[6.0]
  def change
    add_column :rooms, :admin_only, :boolean, default: false, null: false
    ids = [3, 4, 5, 2]
    Room.where.not(id: ids).update(admin_only: true)
  end
end
