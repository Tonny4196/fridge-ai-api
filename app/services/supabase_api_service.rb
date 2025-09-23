require 'faraday'
require 'json'

class SupabaseApiService
  def initialize
    @supabase_url = ENV['SUPABASE_URL']
    @supabase_anon_key = ENV['SUPABASE_ANON_KEY']
  end

  # サインアップ（新規ユーザー作成）
  def sign_up(email, password)
    response = faraday_client.post('/auth/v1/signup') do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        email: email,
        password: password,
        options: {
          email_redirect_to: "#{ENV['FRONTEND_URL'] || 'http://localhost:3000'}/auth/callback"
        }
      }.to_json
    end

    handle_response(response, 'Sign up')
  end

  # サインイン（ログイン）
  def sign_in(email, password)
    response = faraday_client.post('/auth/v1/signin') do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        email: email,
        password: password
      }.to_json
    end

    handle_response(response, 'Sign in')
  end

  # JWTトークンから現在のユーザー情報を取得
  def get_user(access_token)
    response = faraday_client.get('/auth/v1/user') do |req|
      req.headers['Authorization'] = "Bearer #{access_token}"
    end

    handle_response(response, 'Get user')
  end

  private

  def faraday_client
    @faraday_client ||= Faraday.new(
      url: @supabase_url,
      headers: {
        'apikey' => @supabase_anon_key,
        'Content-Type' => 'application/json'
      }
    ) do |f|
      f.response :json
      f.adapter Faraday.default_adapter
    end
  end

  def handle_response(response, action)
    Rails.logger.info "=== Supabase #{action} Response ==="
    Rails.logger.info "Status: #{response.status}"
    Rails.logger.info "Body: #{response.body}"

    case response.status
    when 200, 201
      response.body
    when 400
      error_message = response.body.dig('error_description') || response.body.dig('msg') || 'Bad request'
      raise ::AuthenticationError, error_message
    when 422
      error_message = response.body.dig('error_description') || 'Invalid credentials'
      raise ::AuthenticationError, error_message
    else
      Rails.logger.error "Unexpected status: #{response.status}"
      Rails.logger.error "Response: #{response.body}"
      raise ::AuthenticationError, "Authentication service error"
    end
  end
end