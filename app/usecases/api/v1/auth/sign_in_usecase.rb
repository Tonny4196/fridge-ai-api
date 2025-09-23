module Api
  module V1
    module Auth
      class SignInUsecase
        def initialize(token)
          @form = SignInForm.new(token: token)
        end

        def execute
          unless @form.valid?
            return ['error', @form.errors.full_messages.join(', ')]
          end

          begin
            auth_service = SupabaseAuthService.new
            user = auth_service.verify_token(@form.formatted_token)
            
            ['success', {
              user: UserBlueprint.render_as_hash(user),
              message: 'Sign in successful'
            }]
          rescue ::AuthenticationError => e
            ['error', "Authentication failed: #{e.message}"]
          rescue => e
            Rails.logger.error "=== Auth Sign In Error ==="
            Rails.logger.error "Error: #{e.message}"
            Rails.logger.error "Backtrace: #{e.backtrace.join('\n')}"
            ['error', 'Internal authentication error']
          end
        end
      end
    end
  end
end