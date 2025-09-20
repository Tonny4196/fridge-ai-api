class IngredientBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :quantity, :expiry_date, :image_url, :created_at, :updated_at
end