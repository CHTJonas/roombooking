class AddAdminOnlyToRooms < ActiveRecord::Migration[6.0]
  def change
    add_column :rooms, :admin_only, :boolean, default: false, null: false
    names = ['Dressing Room 1', 'Dressing Room 2', 'Bar', 'Larkum Studio']
    Room.where.not(name: names).update(admin_only: true)
  end
end
