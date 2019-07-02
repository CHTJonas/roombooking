class RemoveUserAgentNullConstraint < ActiveRecord::Migration[5.2]
  def change
    change_column_null :sessions, :user_agent, true
  end
end
