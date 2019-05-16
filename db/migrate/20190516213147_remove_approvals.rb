class RemoveApprovals < ActiveRecord::Migration[5.2]
  def change
    drop_table :application_settings
    remove_column :bookings, :approved
  end
end
