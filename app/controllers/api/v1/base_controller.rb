module Api
  module V1
    class BaseController < ApplicationController
      before_action :authenticate_user!

      private

      def current_user_id
        current_user&.id
      end

      def current_user
        @current_user
      end

      def authenticate_user!
        auth_token = request.headers['Authorization']
        
        unless auth_token.present?
          render json: { status: 'error', data: 'Authorization token required' }, status: :unauthorized
          return
        end

        begin
          cognito_service = AwsCognitoService.new
          @current_user = cognito_service.verify_token(auth_token)
        rescue ::AuthenticationError => e
          render json: { status: 'error', data: "Authentication failed: #{e.message}" }, status: :unauthorized
        rescue => e
          Rails.logger.error "=== Authentication Error ==="
          Rails.logger.error "Error: #{e.message}"
          render json: { status: 'error', data: 'Internal authentication error' }, status: :internal_server_error
        end
      end

      def render_error(message, status = :unprocessable_entity)
        render json: {
          success: false,
          message: message
        }, status: status
      end
    end
  end
end