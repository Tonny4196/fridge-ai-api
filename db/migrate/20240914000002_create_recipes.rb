class CreateRecipes < ActiveRecord::Migration[6.1]
  def change
    create_table :recipes, id: :uuid do |t|
      t.uuid :user_id, null: false
      t.text :title, null: false
      t.jsonb :ingredients
      t.text :instructions
      t.timestamps
    end

    add_index :recipes, :user_id
    add_index :recipes, :created_at
  end
end