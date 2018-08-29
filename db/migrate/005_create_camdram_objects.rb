class CreateCamdramObjects < ActiveRecord::Migration[5.2]
  def change
    create_table :camdram_objects do |t|
      t.string :name
      t.integer :ref_type
      t.integer :camdram_id

      t.timestamps
    end
    add_index :camdram_objects, :type
    add_index :camdram_objects, :camdram_id
  end
end
