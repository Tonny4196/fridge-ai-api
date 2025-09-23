module Api
  module V1
    module Auth
      class SignUpUsecase
        def initialize(token)
          @form = SignInForm.new(token: token)  # 同じFormを使用
        end

        def execute
          unless @form.valid?
            return ['error', @form.errors.full_messages.join(', ')]
          end

          begin
            auth_service = SupabaseAuthService.new
            
            # まず既存ユーザーかチェック
            user_data = auth_service.get_user_data_from_token(@form.formatted_token)
            existing_user = User.find_by(supabase_uid: user_data['sub'])
            
            if existing_user
              # 既存ユーザーがsign_upエンドポイントを使用
              ['error', 'User already exists. Please use sign_in instead.']
            else
              # 新規ユーザーとして処理
              user = auth_service.verify_token(@form.formatted_token)
              setup_new_user(user)
              
              ['success', {
                user: UserBlueprint.render_as_hash(user),
                message: 'Sign up successful! Welcome to the app!',
                is_new_user: true,
                next_step: 'tutorial'
              }]
            end
            
          rescue ::AuthenticationError => e
            ['error', "Authentication failed: #{e.message}"]
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