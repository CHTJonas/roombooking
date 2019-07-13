class ReformulateEmails < ActiveRecord::Migration[5.2]
  def change
    drop_table :emails
    create_table :emails do |t|
      t.jsonb :message, null: false
      t.datetime :created_at
    end
  end
end
