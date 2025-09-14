class Api::V1::IngredientsController < Api::V1::BaseController
  before_action :set_ingredient, only: [:show, :update, :destroy]

  def index
    ingredients = Ingredient.by_user(current_user_id)
    render_success(ingredients)
  end

  def show
    render_success(@ingredient)
  end

  def create
    ingredient = Ingredient.new(ingredient_params)
    ingredient.user_id = current_user_id

    if ingredient.save
      render_success(ingredient, 'Ingredient created successfully')
    else
      render_error(ingredient.errors.full_messages.join(', '))
    end
  end

  def update
    if @ingredient.update(ingredient_params)
      render_success(@ingredient, 'Ingredient updated successfully')
    else
      render_error(@ingredient.errors.full_messages.join(', '))
    end
  end

  def destroy
    @ingredient.destroy
    render_success(nil, 'Ingredient deleted successfully')
  end

  def analyze_image
    unless params[:image].present?
      return render_error('Image is required')
    end

    begin
      service = IngredientAnalysisService.new
      ingredients_data = service.analyze_fridge_image(params[:image])
      
      created_ingredients = []
      ingredients_data.each do |ingredient_data|
        ingredient = Ingredient.create!(
          user_id: current_user_id,
          name: ingredient_data[:name],
          quantity: ingredient_data[:quantity],
          expiry_date: ingredient_data[:expiry_date]
        )
        created_ingredients << ingredient
      end

      render_success(created_ingredients, 'Ingredients analyzed and saved successfully')
    rescue => e
      render_error("Failed to analyze image: #{e.message}")
    end
  end

  private

  def set_ingredient
    @ingredient = Ingredient.by_user(current_user_id).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_error('Ingredient not found', :not_found)
  end

  def ingredient_params
    params.require(:ingredient).permit(:name, :quantity, :expiry_date, :image_url)
  end
end