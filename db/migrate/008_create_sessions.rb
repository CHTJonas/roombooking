class CreateSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :sessions do |t|
      t.references :user, foreign_key: true, null: false
      t.boolean :invalidated, null: false, default: false
      t.datetime :expires_at, null: false
      t.datetime :login_at, null: false
      t.inet :ip, null: false
      t.string :user_agent, null: false
    end
  end
end
