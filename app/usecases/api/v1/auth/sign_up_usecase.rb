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

            # Supabaseに新規ユーザーを作成
            supabase_service = SupabaseApiService.new
            supabase_response = supabase_service.sign_up(@form.email, @form.password)
            
            # ローカルDBにユーザーを作成
            user = create_local_user(supabase_response)
            setup_new_user(user)
            
            ['success', {
              user: UserBlueprint.render_as_hash(user),
              access_token: supabase_response['access_token'],
              refresh_token: supabase_response['refresh_token'],
              expires_in: supabase_response['expires_in'],
              message: 'Sign up successful! Welcome to the app!',
              is_new_user: true,
              next_step: 'tutorial'
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

        def create_local_user(supabase_response)
          user_data = supabase_response['user']
          
          User.create!(
            supabase_uid: user_data['id'],
            email: user_data['email'],
            name: user_data['user_metadata']&.dig('name') || user_data['email']&.split('@')&.first
          )
        end

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