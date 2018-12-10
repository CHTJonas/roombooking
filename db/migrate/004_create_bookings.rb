class CreateBookings < ActiveRecord::Migration[5.2]
  def change
    create_table :bookings do |t|
      t.string :name
      t.text :notes
      t.datetime :start_time
      t.datetime :end_time
      t.date :repeat_until
      t.integer :purpose
      t.integer :camdram_id
      t.boolean :approved
      t.references :venue, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
