module Api
  module V1
    module Recipes
      class CreateUsecase
        def initialize(recipe_params, user_id)
          @recipe_params = recipe_params
          @user_id = user_id
        end

        def execute
          recipe = Recipe.new(@recipe_params)
          recipe.user_id = @user_id

          if recipe.save
            ['success', RecipeBlueprint.render_as_hash(recipe)]
          else
            ['error', recipe.errors.full_messages.join(', ')]
          end
        end
      end
    end
  end
end