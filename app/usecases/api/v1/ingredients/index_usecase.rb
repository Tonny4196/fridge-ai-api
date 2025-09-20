module Api
  module V1
    module Ingredients
      class IndexUsecase
        def initialize(user_id)
          @user_id = user_id
        end

        def execute
          ingredients = Ingredient.by_user(@user_id)
          ['success', IngredientBlueprint.render_as_hash(ingredients)]
        end
      end
    end
  end
end