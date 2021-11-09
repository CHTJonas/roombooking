class AddNotesToRooms < ActiveRecord::Migration[6.1]
  def change
    add_column :rooms, :notes, :text
  end
end
