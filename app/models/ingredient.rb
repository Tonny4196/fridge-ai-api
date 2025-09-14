class Ingredient < ApplicationRecord
  validates :name, presence: true
  validates :user_id, presence: true

  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :expired, -> { where('expiry_date < ?', Date.current) }
  scope :expiring_soon, -> { where(expiry_date: Date.current..1.week.from_now) }
end