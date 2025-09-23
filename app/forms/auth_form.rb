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
    minimum: 8, 
    message: 'Password must be at least 8 characters',
    allow_blank: true
  }
  validates :password, format: {
    with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d\s]).+\z/,
    message: 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one symbol',
    allow_blank: true
  }
end