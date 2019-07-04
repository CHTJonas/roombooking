class AddEmailValidationToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :validated_at, :datetime
    add_column :users, :validation_token, :string
  end
end
