class CreateJoinTablesAttendeesBookings < ActiveRecord::Migration[6.0]
  def change
    create_join_table :attendees, :bookings do |t|
      t.index [:attendee_id, :booking_id], unique: true
    end
  end
end
