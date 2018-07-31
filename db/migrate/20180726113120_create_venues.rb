class CreateVenues < ActiveRecord::Migration[5.2]
  def change
    create_table :venues do |t|
      t.string :name
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :venues, :deleted_at
  end
end
