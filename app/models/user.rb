class User < ApplicationRecord
  # Supabaseトリガーで自動管理されるため、バリデーションは最小限
  validates :email, presence: true
  
  has_many :ingredients, dependent: :destroy
  has_many :recipes, dependent: :destroy

  # IDはSupabaseのauth.users.idと同じUUID
  self.primary_key = 'id'
end