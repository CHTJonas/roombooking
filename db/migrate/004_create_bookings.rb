class CreateBookings < ActiveRecord::Migration[5.2]
  def change
    create_table :bookings do |t|
      t.string :name
      t.text :notes
      t.datetime :when
      t.integer :duration
      t.integer :purpose
      t.integer :camdram_id
      t.references :venue, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
