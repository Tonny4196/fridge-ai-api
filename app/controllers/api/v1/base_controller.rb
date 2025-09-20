module Api
  module V1
    class BaseController < ApplicationController
      private

      def current_user_id
        request.headers['X-User-ID'] || params[:user_id]
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