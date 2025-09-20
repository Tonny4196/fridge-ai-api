module Api
  module V1
    module Recipes
      class IndexUsecase
        def initialize(user_id)
          @user_id = user_id
        end

        def execute
          recipes = Recipe.by_user(@user_id).recent
          ['success', RecipeBlueprint.render_as_hash(recipes)]
        end
      end
    end
  end
end