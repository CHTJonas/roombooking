class DeviseCreateUserSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :user_sessions do |t|
      t.integer :user_id
      t.string :session_id
      t.string :ip
      t.string :user_agent
      t.timestamps
    end
    add_index(:user_sessions, :user_id)
    add_index(:user_sessions, :session_id, unique: true)
  end
end
