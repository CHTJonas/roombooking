class AddExcludedRepeatDatesToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :excluded_repeat_dates, :string
  end
end
