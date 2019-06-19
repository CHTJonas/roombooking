class CreateEmails < ActiveRecord::Migration[5.2]
  def change
    create_table :emails do |t|
      t.string :from, null: false
      t.string :to, null: false
      t.string :subject, null: false
      t.text :body, null: false
      t.timestamps
    end
  end
end
