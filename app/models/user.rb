class User < ApplicationRecord
  # AWS Cognitoで管理されるユーザー情報
  validates :email, presence: true
  validates :cognito_sub, presence: true, uniqueness: true
  
  has_many :ingredients, dependent: :destroy
  has_many :recipes, dependent: :destroy

  # IDはUUID形式
  self.primary_key = 'id'
end