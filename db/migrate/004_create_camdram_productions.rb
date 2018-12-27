class CreateCamdramProductions < ActiveRecord::Migration[5.2]
  def change
    create_table :camdram_productions do |t|
      t.integer :camdram_id, null: false
      t.integer :max_bookings, default: 0, null: false
      t.timestamps
    end
  end
end
