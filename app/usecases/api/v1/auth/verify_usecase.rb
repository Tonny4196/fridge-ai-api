module Api
  module V1
    module Auth
      class VerifyUsecase
        def initialize(token)
          @token = token
        end

        def execute
          unless @token.present?
            return ['error', 'Authorization token is required']
          end

          begin
            auth_service = SupabaseAuthService.new
            user = auth_service.verify_token(@token)
            
            ['success', {
              user: UserBlueprint.render_as_hash(user),
              message: 'Token verified successfully'
            }]
          rescue SupabaseAuthService::AuthenticationError => e
            ['error', "Authentication failed: #{e.message}"]
          rescue => e
            Rails.logger.error "=== Auth Verify Error ==="
            Rails.logger.error "Error: #{e.message}"
            Rails.logger.error "Backtrace: #{e.backtrace.join('\n')}"
            ['error', 'Internal authentication error']
          end
        end
      end
    end
  end
end