module Api
  module V1
    module Recipes
      class ShowUsecase
        def initialize(recipe_id, user_id)
          @recipe_id = recipe_id
          @user_id = user_id
        end

        def execute
          recipe = Recipe.by_user(@user_id).find(@recipe_id)
          ['success', RecipeBlueprint.render_as_hash(recipe)]
        rescue ActiveRecord::RecordNotFound
          ['error', 'Recipe not found']
        end
      end
    end
  end
end