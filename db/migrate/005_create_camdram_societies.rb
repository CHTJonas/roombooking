class CreateCamdramSocieties < ActiveRecord::Migration[5.2]
  def change
    create_table :camdram_societies do |t|
      t.bigint :camdram_id, null: false
      t.integer :max_meetings, default: 0, null: false
      t.boolean :active, default: false, null: false
      t.timestamps
    end
    add_index :camdram_societies, :camdram_id, unique: true
    add_index :camdram_societies, :active, where: 'active = true'
  end
end
