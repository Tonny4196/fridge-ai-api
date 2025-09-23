module Api
  module V1
    module Auth
      class MeUsecase
        def initialize(user)
          @user = user
        end

        def execute
          unless @user
            return ['error', 'User not authenticated']
          end

          begin
            ['success', {
              user: UserBlueprint.render_as_hash(@user),
              message: 'User information retrieved successfully'
            }]
          rescue => e
            Rails.logger.error "=== Auth Me Error ==="
            Rails.logger.error "Error: #{e.message}"
            Rails.logger.error "Backtrace: #{e.backtrace.join('\n')}"
            ['error', 'Failed to retrieve user information']
          end
        end
      end
    end
  end
end