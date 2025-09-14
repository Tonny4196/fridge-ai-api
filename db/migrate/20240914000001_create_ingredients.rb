class CreateIngredients < ActiveRecord::Migration[6.1]
  def change
    create_table :ingredients, id: :uuid do |t|
      t.uuid :user_id, null: false
      t.text :name, null: false
      t.text :quantity
      t.date :expiry_date
      t.text :image_url
      t.timestamps
    end

    add_index :ingredients, :user_id
    add_index :ingredients, :expiry_date
  end
end