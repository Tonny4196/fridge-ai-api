class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :supabase_uid, null: false
      t.string :email, null: false
      t.string :name

      t.timestamps
    end

    add_index :users, :supabase_uid, unique: true
    add_index :users, :email, unique: true
  end
end