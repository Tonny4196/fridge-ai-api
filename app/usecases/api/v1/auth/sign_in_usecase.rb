module Api
  module V1
    module Auth
      class SignInUsecase
        def initialize(params)
          @form = AuthForm.new(params)
        end

        def execute
          unless @form.valid?
            return ['error', @form.errors.full_messages.join(', ')]
          end

          begin
            # AWS Cognitoで認証
            cognito_service = AwsCognitoAuthService.new
            auth_response = cognito_service.sign_in(@form.email, @form.password)
            
            # アクセストークンからユーザー情報を取得
            user_info = cognito_service.get_user_info(auth_response[:access_token])
            
            # ローカルデータベースからユーザーを取得
            user = User.find_by(cognito_sub: user_info[:sub])
            
            unless user
              return ['error', 'User not found in local database. Please contact support.']
            end
            
            # ログイン時の処理（最終ログイン時刻更新など）
            update_sign_in_info(user)
            
            ['success', {
              user: UserBlueprint.render_as_hash(user),
              access_token: auth_response[:access_token],
              id_token: auth_response[:id_token],
              refresh_token: auth_response[:refresh_token],
              expires_in: auth_response[:expires_in],
              token_type: auth_response[:token_type],
              message: 'Sign in successful',
              is_new_user: false
            }]
          rescue ::AuthenticationError => e
            ['error', e.message]
          rescue => e
            Rails.logger.error "=== Auth Sign In Error ==="
            Rails.logger.error "Error: #{e.message}"
            Rails.logger.error "Backtrace: #{e.backtrace.join('\n')}"
            ['error', 'Internal authentication error']
          end
        end

        private

        def update_sign_in_info(user)
          # 将来的にログイン時の処理を追加
          # - 最終ログイン時刻の更新
          # - ログイン回数のカウント
          # - ログイン履歴の記録
          Rails.logger.info "User signed in: #{user.id}"
        end
      end
    end
  end
end