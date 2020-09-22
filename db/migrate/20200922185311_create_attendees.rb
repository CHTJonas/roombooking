class CreateAttendees < ActiveRecord::Migration[6.0]
  def change
    create_table :attendees do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.timestamps
    end
    add_index :attendees, :email, unique: true
  end
end
