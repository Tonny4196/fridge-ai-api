class RecipeBlueprint < Blueprinter::Base
  identifier :id

  fields :title, :ingredients, :instructions, :created_at, :updated_at
end