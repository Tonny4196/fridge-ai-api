module Api
  module V1
    module Ingredients
      class CreateUsecase
        def initialize(ingredient_params, user_id)
          @ingredient_params = ingredient_params
          @user_id = user_id
        end

        def execute
          ingredient = Ingredient.new(@ingredient_params)
          ingredient.user_id = @user_id

          if ingredient.save
            ['success', IngredientBlueprint.render_as_hash(ingredient)]
          else
            ['error', ingredient.errors.full_messages.join(', ')]
          end
        end
      end
    end
  end
end