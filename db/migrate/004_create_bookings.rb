class CreateBookings < ActiveRecord::Migration[5.2]
  def change
    create_table :bookings do |t|
      t.string :name, null: false
      t.text :notes
      t.datetime :start_time, null: false, index: true
      t.datetime :end_time, null: false
      t.date :repeat_until, index: true
      t.integer :repeat_mode, default: 0, null: false
      t.integer :purpose, null: false
      t.integer :camdram_id
      t.boolean :approved, default: false, null: false
      t.references :venue, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false

      t.timestamps
    end
  end
end
