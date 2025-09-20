module Api
  module V1
    module Ingredients
      class UpdateUsecase
        def initialize(ingredient_id, ingredient_params, user_id)
          @ingredient_id = ingredient_id
          @ingredient_params = ingredient_params
          @user_id = user_id
        end

        def execute
          ingredient = Ingredient.by_user(@user_id).find(@ingredient_id)
          
          if ingredient.update(@ingredient_params)
            ['success', IngredientBlueprint.render_as_hash(ingredient)]
          else
            ['error', ingredient.errors.full_messages.join(', ')]
          end
        rescue ActiveRecord::RecordNotFound
          ['error', 'Ingredient not found']
        end
      end
    end
  end
end