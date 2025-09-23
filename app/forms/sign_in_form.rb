class SignInForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :token, :string

  validates :token, presence: { message: 'Authorization token is required' }
  validates :token, format: { 
    with: /\A[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]*\z/, 
    message: 'Invalid JWT token format',
    allow_blank: true
  }

  def formatted_token
    return nil unless token.present?
    
    # Bearerプレフィックスを除去
    token.gsub(/^Bearer\s+/i, '')
  end
end