class User < ApplicationRecord
  validates :supabase_uid, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  
  has_many :ingredients, dependent: :destroy
  has_many :recipes, dependent: :destroy
end