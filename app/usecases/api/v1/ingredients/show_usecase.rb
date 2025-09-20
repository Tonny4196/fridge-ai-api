module Api
  module V1
    module Ingredients
      class ShowUsecase
        def initialize(ingredient_id, user_id)
          @ingredient_id = ingredient_id
          @user_id = user_id
        end

        def execute
          ingredient = Ingredient.by_user(@user_id).find(@ingredient_id)
          ['success', IngredientBlueprint.render_as_hash(ingredient)]
        rescue ActiveRecord::RecordNotFound
          ['error', 'Ingredient not found']
        end
      end
    end
  end
end