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
            # Supabaseで認証
            supabase_service = SupabaseApiService.new
            supabase_response = supabase_service.sign_in(@form.email, @form.password)
            
            # ローカルDBのユーザーを取得
            user_data = supabase_response['user']
            user = User.find_by(supabase_uid: user_data['id'])
            
            unless user
              # ローカルDBにユーザーが存在しない場合は作成
              user = User.create!(
                supabase_uid: user_data['id'],
                email: user_data['email'],
                name: user_data['user_metadata']&.dig('name') || user_data['email']&.split('@')&.first
              )
            end
            
            # ログイン時の処理（最終ログイン時刻更新など）
            update_sign_in_info(user)
            
            ['success', {
              user: UserBlueprint.render_as_hash(user),
              access_token: supabase_response['access_token'],
              refresh_token: supabase_response['refresh_token'],
              expires_in: supabase_response['expires_in'],
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