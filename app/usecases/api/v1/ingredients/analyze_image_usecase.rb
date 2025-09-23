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
            
            Rails.logger.info "=== UseCase: Parsed ingredients data ==="
            Rails.logger.info "Ingredients count: #{ingredients_data.length}"
            Rails.logger.info "User ID: #{@user_id}"
            
            if ingredients_data.empty?
              Rails.logger.warn "No ingredients data received from OpenAI service"
              return ['error', 'No ingredients detected in the image']
            end
            
            # Bulk insert用のデータを準備
            insert_data = ingredients_data.map do |ingredient_data|
              {
                user_id: @user_id,
                name: ingredient_data[:name],
                quantity: ingredient_data[:quantity],
                expiry_date: ingredient_data[:expiry_date],
                created_at: Time.current,
                updated_at: Time.current
              }
            end
            
            Rails.logger.info "=== Bulk inserting #{insert_data.length} ingredients ==="
            
            # Bulk insertでパフォーマンス向上
            result = Ingredient.insert_all(insert_data, returning: [:id, :name, :quantity, :expiry_date, :user_id])
            
            # 作成されたレコードを取得
            created_ingredient_ids = result.pluck('id')
            created_ingredients = Ingredient.where(id: created_ingredient_ids)
            
            Rails.logger.info "=== Successfully created #{created_ingredients.count} ingredients ==="
            ['success', IngredientBlueprint.render_as_hash(created_ingredients)]
          rescue => e
            Rails.logger.error "=== UseCase Error ==="
            Rails.logger.error "Error class: #{e.class}"
            Rails.logger.error "Error message: #{e.message}"
            Rails.logger.error "Backtrace: #{e.backtrace.join('\n')}"
            ['error', "Failed to analyze image: #{e.message}"]
          end
        end
      end
    end
  end
end