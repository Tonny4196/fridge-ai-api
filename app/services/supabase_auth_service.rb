require 'jwt'
require 'net/http'
require 'json'

class SupabaseAuthService
  class AuthenticationError < StandardError; end
  
  def initialize
    @supabase_url = ENV['SUPABASE_URL']
    @supabase_jwt_secret = ENV['SUPABASE_JWT_SECRET']
  end

  # JWTトークンを検証してユーザー情報を返す
  def verify_token(token)
    return nil unless token

    begin
      # Bearerプレフィックスを除去
      token = token.gsub(/^Bearer\s+/, '')
      
      # JWTトークンをデコード
      payload = JWT.decode(token, @supabase_jwt_secret, true, { algorithm: 'HS256' })
      user_data = payload[0]
      
      Rails.logger.info "=== Supabase Auth: Token verified ==="
      Rails.logger.info "User ID: #{user_data['sub']}"
      Rails.logger.info "Email: #{user_data['email']}"
      Rails.logger.info "Role: #{user_data['role']}"
      
      # ユーザーをデータベースで検索または作成
      find_or_create_user(user_data)
      
    rescue JWT::DecodeError => e
      Rails.logger.error "=== JWT Decode Error ==="
      Rails.logger.error "Error: #{e.message}"
      Rails.logger.error "Token: #{token[0..20]}..." if token
      raise AuthenticationError, "Invalid token: #{e.message}"
    rescue => e
      Rails.logger.error "=== Supabase Auth Error ==="
      Rails.logger.error "Error: #{e.message}"
      Rails.logger.error "Backtrace: #{e.backtrace.join('\n')}"
      raise AuthenticationError, "Authentication failed: #{e.message}"
    end
  end

  private

  def find_or_create_user(user_data)
    supabase_uid = user_data['sub']
    email = user_data['email']
    name = user_data['user_metadata']&.dig('name') || 
           user_data['user_metadata']&.dig('full_name') || 
           email&.split('@')&.first

    user = User.find_by(supabase_uid: supabase_uid)
    
    if user
      # 既存ユーザーの情報を更新
      user.update!(
        email: email,
        name: name
      )
      Rails.logger.info "=== Updated existing user: #{user.id} ==="
    else
      # 新規ユーザーを作成
      user = User.create!(
        supabase_uid: supabase_uid,
        email: email,
        name: name
      )
      Rails.logger.info "=== Created new user: #{user.id} ==="
    end

    user
  end
end