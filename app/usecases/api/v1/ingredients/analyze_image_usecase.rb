module Api
  module V1
    module Ingredients
      class AnalyzeImageUsecase
        def initialize(image_url, user_id)
          @image_url = image_url
          @user_id = user_id
        end

        def execute
          unless @image_url.present?
            return ['error', 'Image URL is required']
          end

          begin
            service = IngredientAnalysisService.new
            ingredients_data = service.analyze_fridge_image(@image_url)
            
            created_ingredients = []
            ingredients_data.each do |ingredient_data|
              ingredient = Ingredient.create!(
                user_id: @user_id,
                name: ingredient_data[:name],
                quantity: ingredient_data[:quantity],
                expiry_date: ingredient_data[:expiry_date]
              )
              created_ingredients << ingredient
            end

            ['success', IngredientBlueprint.render_as_hash(created_ingredients)]
          rescue => e
            ['error', "Failed to analyze image: #{e.message}"]
          end
        end
      end
    end
  end
end