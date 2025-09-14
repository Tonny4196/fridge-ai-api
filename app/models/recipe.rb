class Recipe < ApplicationRecord
  validates :title, presence: true
  validates :user_id, presence: true

  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :recent, -> { order(created_at: :desc) }

  def ingredients_list
    return [] unless ingredients.is_a?(Array)
    ingredients
  end

  def add_ingredient(name, quantity = nil)
    self.ingredients ||= []
    self.ingredients << { name: name, quantity: quantity }
  end
end