module Api
  module V1
    class RecipesController < Api::V1::BaseController
      def index
        status, data = Api::V1::Recipes::IndexUsecase.new(current_user_id).execute
        render json: { status: status, data: data }
      end

      def show
        status, data = Api::V1::Recipes::ShowUsecase.new(params[:id], current_user_id).execute
        render json: { status: status, data: data }
      end

      def create
        status, data = Api::V1::Recipes::CreateUsecase.new(recipe_params, current_user_id).execute
        render json: { status: status, data: data }
      end

      def generate
        status, data = Api::V1::Recipes::GenerateUsecase.new(current_user_id).execute
        render json: { status: status, data: data }
      end

      def destroy
        status, data = Api::V1::Recipes::DestroyUsecase.new(params[:id], current_user_id).execute
        render json: { status: status, data: data }
      end

      private

      def recipe_params
        params.require(:recipe).permit(:title, :instructions, ingredients: [])
      end
    end
  end
end