module Api
  module V1
    module Auth
      class SignUpUsecase
        def initialize(params)
          @form = AuthForm.new(params)
        end

        def execute
          unless @form.valid?
            return ['error', @form.errors.full_messages.join(', ')]
          end

          begin
            # 既存ユーザーのチェック
            existing_user = User.find_by(email: @form.email)
            if existing_user
              return ['error', 'User already exists. Please use sign_in instead.']
            end

            # AWS Cognitoに新規ユーザーを作成
            cognito_service = AwsCognitoAuthService.new
            cognito_user = cognito_service.sign_up(@form.email, @form.password)
            
            # Cognitoのサブジェクト（sub）を取得
            cognito_sub = cognito_user.attributes.find { |attr| attr.name == 'sub' }&.value
            
            # ローカルデータベースにユーザーを作成
            user = User.create!(
              id: SecureRandom.uuid,
              cognito_sub: cognito_sub,
              email: @form.email,
              email_verified: true,
              name: @form.email.split('@').first
            )
            
            setup_new_user(user)
            
            ['success', {
              user: UserBlueprint.render_as_hash(user),
              message: 'Sign up successful! Welcome to the app!',
              is_new_user: true,
              next_step: 'Please sign in to get access tokens'
            }]
            
          rescue ::AuthenticationError => e
            ['error', e.message]
          rescue => e
            Rails.logger.error "=== Auth Sign Up Error ==="
            Rails.logger.error "Error: #{e.message}"
            Rails.logger.error "Backtrace: #{e.backtrace.join('\n')}"
            ['error', 'Internal authentication error']
          end
        end

        private

        def setup_new_user(user)
          Rails.logger.info "=== Setting up new user: #{user.id} ==="
          
          # 新規ユーザー向けの初期設定
          # 将来的にここに以下のような処理を追加可能:
          # - デフォルト設定の作成
          # - ウェルカムボーナスの付与  
          # - チュートリアル進捗の初期化
          # - 初回ログイン履歴の記録
          
          Rails.logger.info "New user setup completed for user: #{user.id}"
        end
      end
    end
  end
end