class CreateCamdramVenuesRoomsRelationTable < ActiveRecord::Migration[5.2]
  def change
    create_table :camdram_venues_rooms, id: false do |t|
      t.belongs_to :camdram_venue, index: true
      t.belongs_to :room, index: true
    end
  end
end
