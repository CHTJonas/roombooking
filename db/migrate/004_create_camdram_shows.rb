class CreateCamdramShows < ActiveRecord::Migration[5.2]
  def change
    create_table :camdram_shows do |t|
      t.bigint :camdram_id, null: false
      t.integer :max_rehearsals, default: 0, null: false
      t.integer :max_auditions, default: 0, null: false
      t.integer :max_meetings, default: 0, null: false
      t.boolean :active, default: false, null: false
      t.timestamps
    end
    add_index :camdram_shows, :camdram_id, unique: true
    add_index :camdram_shows, :active, where: 'active = true'
  end
end
