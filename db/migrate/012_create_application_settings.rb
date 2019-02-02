class CreateApplicationSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :application_settings do |t|
      t.boolean :auto_approve_bookings, default: false, null: false
    end
  end
end
