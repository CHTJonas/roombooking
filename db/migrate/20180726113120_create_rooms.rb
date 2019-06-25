class CreateRooms < ActiveRecord::Migration[5.2]
  def change
    create_table :rooms do |t|
      t.string :name, null: false
      t.string :camdram_venues, array: true, null: true
      t.timestamps
    end
  end
end
