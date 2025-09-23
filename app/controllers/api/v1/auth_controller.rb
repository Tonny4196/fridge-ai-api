module Api
  module V1
    class AuthController < Api::V1::BaseController
      # 認証をスキップ（認証前のエンドポイントのため）
      skip_before_action :authenticate_user!, only: [:sign_up, :sign_in]

      def sign_up
        status, data = Api::V1::Auth::SignUpUsecase.new(auth_params).execute
        render json: { status: status, data: data }
      end

      def sign_in
        status, data = Api::V1::Auth::SignInUsecase.new(auth_params).execute
        render json: { status: status, data: data }
      end

      def me
        status, data = Api::V1::Auth::MeUsecase.new(current_user).execute
        render json: { status: status, data: data }
      end

      private

      def auth_params
        params.permit(:email, :password)
      end
    end
  end
end