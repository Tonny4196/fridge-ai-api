module Api
  module V1
    module Recipes
      class DestroyUsecase
        def initialize(recipe_id, user_id)
          @recipe_id = recipe_id
          @user_id = user_id
        end

        def execute
          recipe = Recipe.by_user(@user_id).find(@recipe_id)
          recipe.destroy
          ['success', nil]
        rescue ActiveRecord::RecordNotFound
          ['error', 'Recipe not found']
        end
      end
    end
  end
end