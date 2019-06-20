class CreateCamdramVenues < ActiveRecord::Migration[5.2]
  def change
    create_table :camdram_venues do |t|
      t.bigint :camdram_id, null: false
      t.timestamps
    end
    remove_column :rooms, :camdram_venues
    add_index :camdram_venues, :camdram_id, unique: true
  end
end
