module Api
  module V1
    module Recipes
      class GenerateUsecase
        def initialize(user_id)
          @user_id = user_id
        end

        def execute
          user_ingredients = Ingredient.by_user(@user_id)
          
          if user_ingredients.empty?
            return ['error', 'No ingredients found for user']
          end

          begin
            service = RecipeGenerationService.new
            recipe_data = service.generate_recipe_from_ingredients(user_ingredients)

            recipe = Recipe.create!(
              user_id: @user_id,
              title: recipe_data[:title],
              ingredients: recipe_data[:ingredients],
              instructions: recipe_data[:instructions]
            )

            ['success', RecipeBlueprint.render_as_hash(recipe)]
          rescue => e
            ['error', "Failed to generate recipe: #{e.message}"]
          end
        end
      end
    end
  end
end