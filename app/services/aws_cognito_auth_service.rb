require 'aws-sdk-cognitoidentityprovider'

class AwsCognitoAuthService
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

  # サインアップ
  def sign_up(email, password)
    response = @client.admin_create_user({
      user_pool_id: @user_pool_id,
      username: email,
      user_attributes: [
        {
          name: 'email',
          value: email
        },
        {
          name: 'email_verified',
          value: 'true'
        }
      ],
      temporary_password: password,
      message_action: 'SUPPRESS' # ウェルカムメールを送信しない
    })

    # パスワードを永続化
    @client.admin_set_user_password({
      user_pool_id: @user_pool_id,
      username: email,
      password: password,
      permanent: true
    })

    Rails.logger.info "=== Cognito Sign up Success ==="
    Rails.logger.info "User: #{response.user.username}"
    Rails.logger.info "Sub: #{response.user.attributes.find { |attr| attr.name == 'sub' }&.value}"

    response.user

  rescue Aws::CognitoIdentityProvider::Errors::UsernameExistsException
    raise ::AuthenticationError, 'User already exists. Please use sign_in instead.'
  rescue Aws::CognitoIdentityProvider::Errors::ServiceError => e
    Rails.logger.error "Cognito sign_up error: #{e.message}"
    raise ::AuthenticationError, "Sign up failed: #{e.message}"
  end

  # サインイン
  def sign_in(email, password)
    response = @client.admin_initiate_auth({
      user_pool_id: @user_pool_id,
      client_id: @client_id,
      auth_flow: 'ADMIN_NO_SRP_AUTH',
      auth_parameters: {
        'USERNAME' => email,
        'PASSWORD' => password
      }
    })

    Rails.logger.info "=== Cognito Sign in Success ==="
    Rails.logger.info "Access Token: #{response.authentication_result.access_token[0..20]}..."
    Rails.logger.info "ID Token: #{response.authentication_result.id_token[0..20]}..."

    {
      access_token: response.authentication_result.access_token,
      id_token: response.authentication_result.id_token,
      refresh_token: response.authentication_result.refresh_token,
      expires_in: response.authentication_result.expires_in,
      token_type: response.authentication_result.token_type
    }

  rescue Aws::CognitoIdentityProvider::Errors::NotAuthorizedException
    raise ::AuthenticationError, 'Invalid email or password'
  rescue Aws::CognitoIdentityProvider::Errors::UserNotConfirmedException
    raise ::AuthenticationError, 'User account is not confirmed'
  rescue Aws::CognitoIdentityProvider::Errors::ServiceError => e
    Rails.logger.error "Cognito sign_in error: #{e.message}"
    raise ::AuthenticationError, "Sign in failed: #{e.message}"
  end

  # ユーザー情報取得
  def get_user_info(access_token)
    response = @client.get_user({
      access_token: access_token
    })

    user_attributes = {}
    response.user_attributes.each do |attr|
      user_attributes[attr.name] = attr.value
    end

    {
      username: response.username,
      user_attributes: user_attributes,
      sub: user_attributes['sub'],
      email: user_attributes['email'],
      email_verified: user_attributes['email_verified'] == 'true'
    }

  rescue Aws::CognitoIdentityProvider::Errors::ServiceError => e
    Rails.logger.error "Cognito get_user error: #{e.message}"
    raise ::AuthenticationError, "Failed to get user info: #{e.message}"
  end
end