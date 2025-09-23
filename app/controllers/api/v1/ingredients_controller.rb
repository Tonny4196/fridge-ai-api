module Api
  module V1
    class IngredientsController < Api::V1::BaseController
      def index
        status, data = Api::V1::Ingredients::IndexUsecase.new(current_user_id).execute
        render json: { status: status, data: data }
      end

      def show
        status, data = Api::V1::Ingredients::ShowUsecase.new(params[:id], current_user_id).execute
        render json: { status: status, data: data }
      end

      def create
        status, data = Api::V1::Ingredients::CreateUsecase.new(ingredient_params, current_user_id).execute
        render json: { status: status, data: data }
      end

      def update
        status, data = Api::V1::Ingredients::UpdateUsecase.new(params[:id], ingredient_params, current_user_id).execute
        render json: { status: status, data: data }
      end

      def destroy
        status, data = Api::V1::Ingredients::DestroyUsecase.new(params[:id], current_user_id).execute
        render json: { status: status, data: data }
      end

      def analyze_image
        status, data = Api::V1::Ingredients::AnalyzeImageUsecase.new(params[:image_url], current_user_id).execute
        render json: { status: status, data: data }
      end

      private

      def ingredient_params
        params.require(:ingredient).permit(:name, :quantity, :expiry_date, :image_url)
      end
    end
  end
end