module Api
  module V1
    class AuthController < Api::V1::BaseController
      # 認証をスキップ（認証前のエンドポイントのため）
      skip_before_action :authenticate_user!, only: [:sign_in]

      def sign_in
        status, data = Api::V1::Auth::SignInUsecase.new(auth_token).execute
        render json: { status: status, data: data }
      end

      def me
        status, data = Api::V1::Auth::MeUsecase.new(current_user).execute
        render json: { status: status, data: data }
      end

      private

      def auth_token
        request.headers['Authorization']
      end
    end
  end
end