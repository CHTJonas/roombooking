class CreateCamdramSocieties < ActiveRecord::Migration[5.2]
  def change
    create_table :camdram_societies do |t|
      t.integer :camdram_id, null: false, unique: true
      t.integer :max_bookings, default: 0, null: false
      t.boolean :active, default: false, null: false
      t.timestamps
    end
  end
end
