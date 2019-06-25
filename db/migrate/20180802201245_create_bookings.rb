class CreateBookings < ActiveRecord::Migration[5.2]
  def change
    create_table :bookings do |t|
      t.string :name, null: false
      t.text :notes
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.date :repeat_until
      t.string :excluded_repeat_dates
      t.integer :repeat_mode, default: 0, null: false
      t.integer :purpose, null: false
      t.references :room, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false
      t.references :camdram_model, polymorphic: true, null: true
      t.timestamps
    end
    add_index :bookings, :start_time
    add_index :bookings, :end_time
    add_index :bookings, :repeat_until
    add_index :bookings, :repeat_mode, where: 'repeat_mode <> 0'
    add_index :bookings, :created_at, order: { created_at: :desc }
  end
end
