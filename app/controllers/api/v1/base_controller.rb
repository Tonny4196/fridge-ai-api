class Api::V1::BaseController < ApplicationController
  private

  def current_user_id
    request.headers['X-User-ID'] || params[:user_id]
  end

  def render_success(data = nil, message = 'Success')
    render json: {
      success: true,
      message: message,
      data: data
    }
  end

  def render_error(message, status = :unprocessable_entity)
    render json: {
      success: false,
      message: message
    }, status: status
  end
end