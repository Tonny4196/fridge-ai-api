class AuthForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :email, :string
  attribute :password, :string

  validates :email, presence: { message: 'Email is required' }
  validates :email, format: { 
    with: URI::MailTo::EMAIL_REGEXP, 
    message: 'Invalid email format',
    allow_blank: true
  }
  validates :password, presence: { message: 'Password is required' }
  validates :password, length: { 
    minimum: 6, 
    message: 'Password must be at least 6 characters',
    allow_blank: true
  }
end