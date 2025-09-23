class AddCognitoSubToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :cognito_sub, :string, null: false
    add_column :users, :email_verified, :boolean, default: false
    
    add_index :users, :cognito_sub, unique: true
  end
end
