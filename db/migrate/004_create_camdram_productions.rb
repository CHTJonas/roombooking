class CreateCamdramProductions < ActiveRecord::Migration[5.2]
  def change
    create_table :camdram_productions do |t|
      t.bigint :camdram_id, null: false
      t.integer :max_bookings, default: 0, null: false
      t.boolean :active, default: false, null: false
      t.timestamps
    end
    add_index :camdram_productions, :camdram_id, unique: true
    add_index :camdram_productions, :active, where: 'active = true'
  end
end
