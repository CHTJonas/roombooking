class DropAttendeesTables < ActiveRecord::Migration[6.1]
  def change
    ActiveRecord::Base.transaction do
      drop_join_table :attendees, :bookings
      drop_table :attendees
    end
  end
end
