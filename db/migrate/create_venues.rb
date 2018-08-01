class CreateVenues < ActiveRecord::Migration[5.2]
  def change
    create_table :venues do |t|
      t.string :name

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
