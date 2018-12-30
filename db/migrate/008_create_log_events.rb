class CreateLogEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :log_events do |t|
      t.references :logable, polymorphic: true
      t.integer :outcome
      t.string :action
      t.integer :interface, index: true
      t.string :ip, index: true
      t.string :user_agent
      t.timestamps
    end
  end
end
