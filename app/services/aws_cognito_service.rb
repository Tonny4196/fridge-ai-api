require 'aws-sdk-cognitoidentityprovider'
require 'jwt'
require 'net/http'
require 'json'

class AwsCognitoService
  def initialize
    @region = ENV['AWS_COGNITO_REGION'] || 'ap-northeast-1'
    @user_pool_id = ENV['AWS_COGNITO_USER_POOL_ID']
    @client_id = ENV['AWS_COGNITO_CLIENT_ID']
    
    raise 'AWS Cognito configuration missing' unless @user_pool_id && @client_id
    
    @client = Aws::CognitoIdentityProvider::Client.new(
      region: @region,
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    )
  end

  # JWTトークンを検証してユーザー情報を返す
  def verify_token(token)
    # Bearer prefixを削除
    clean_token = token.gsub(/^Bearer\s+/, '')
    
    # JWTトークンをデコード（署名検証なし、まずはペイロードを取得）
    payload = JWT.decode(clean_token, nil, false)[0]
    
    # Cognitoの公開キーで署名を検証
    verify_signature(clean_token, payload)
    
    # トークンの有効期限チェック
    if payload['exp'] < Time.now.to_i
      raise ::AuthenticationError, 'Token expired'
    end
    
    # ユーザー情報を構築
    user_data = {
      'sub' => payload['sub'],
      'email' => payload['email'],
      'email_verified' => payload['email_verified'],
      'cognito:username' => payload['cognito:username']
    }
    
    Rails.logger.info "=== AWS Cognito: Token verified ==="
    Rails.logger.info "User ID: #{user_data['sub']}"
    Rails.logger.info "Email: #{user_data['email']}"
    
    # ユーザーをデータベースで検索または作成
    find_or_create_user(user_data)
    
  rescue JWT::DecodeError => e
    Rails.logger.error "JWT decode error: #{e.message}"
    raise ::AuthenticationError, "Invalid token: #{e.message}"
  rescue => e
    Rails.logger.error "=== AWS Cognito Auth Error ==="
    Rails.logger.error "Error: #{e.message}"
    Rails.logger.error "Backtrace: #{e.backtrace.join('\n')}"
    raise ::AuthenticationError, "Authentication failed: #{e.message}"
  end

  private

  # Cognito公開キーでJWT署名を検証
  def verify_signature(token, payload)
    # Cognito JWKs (JSON Web Key Set) を取得
    jwks_uri = "https://cognito-idp.#{@region}.amazonaws.com/#{@user_pool_id}/.well-known/jwks.json"
    jwks_response = Net::HTTP.get_response(URI(jwks_uri))
    
    unless jwks_response.code == '200'
      raise ::AuthenticationError, 'Failed to fetch JWKS'
    end
    
    jwks = JSON.parse(jwks_response.body)
    
    # トークンのヘッダーからkidを取得
    header = JWT.decode(token, nil, false, { verify_expiration: false })[1]
    kid = header['kid']
    
    # 対応する公開キーを検索
    key_data = jwks['keys'].find { |key| key['kid'] == kid }
    unless key_data
      raise ::AuthenticationError, 'Public key not found'
    end
    
    # 公開キーでJWTを検証
    rsa_key = JWT::JWK.import(key_data).keypair
    JWT.decode(token, rsa_key, true, { algorithm: 'RS256' })
    
  rescue JWT::VerificationError => e
    raise ::AuthenticationError, "Token verification failed: #{e.message}"
  end

  def find_or_create_user(user_data)
    cognito_sub = user_data['sub']
    email = user_data['email']
    
    # cognito_subで既存ユーザーを検索
    user = User.find_by(cognito_sub: cognito_sub)
    
    if user
      # 既存ユーザーの情報を更新
      user.update!(
        email: email,
        email_verified: user_data['email_verified']
      )
      Rails.logger.info "=== Updated existing user: #{user.id} ==="
    else
      # 新規ユーザーを作成
      user = User.create!(
        id: SecureRandom.uuid,
        cognito_sub: cognito_sub,
        email: email,
        email_verified: user_data['email_verified'],
        name: email&.split('@')&.first
      )
      Rails.logger.info "=== Created new user: #{user.id} ==="
    end

    user
  end
end