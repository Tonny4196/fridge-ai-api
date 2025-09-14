class Api::V1::RecipesController < Api::V1::BaseController
  before_action :set_recipe, only: [:show, :destroy]

  def index
    recipes = Recipe.by_user(current_user_id).recent
    render_success(recipes)
  end

  def show
    render_success(@recipe)
  end

  def create
    recipe = Recipe.new(recipe_params)
    recipe.user_id = current_user_id

    if recipe.save
      render_success(recipe, 'Recipe created successfully')
    else
      render_error(recipe.errors.full_messages.join(', '))
    end
  end

  def generate
    begin
      user_ingredients = Ingredient.by_user(current_user_id)
      
      if user_ingredients.empty?
        return render_error('No ingredients found for user')
      end

      service = RecipeGenerationService.new
      recipe_data = service.generate_recipe_from_ingredients(user_ingredients)

      recipe = Recipe.create!(
        user_id: current_user_id,
        title: recipe_data[:title],
        ingredients: recipe_data[:ingredients],
        instructions: recipe_data[:instructions]
      )

      render_success(recipe, 'Recipe generated successfully')
    rescue => e
      render_error("Failed to generate recipe: #{e.message}")
    end
  end

  def destroy
    @recipe.destroy
    render_success(nil, 'Recipe deleted successfully')
  end

  private

  def set_recipe
    @recipe = Recipe.by_user(current_user_id).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_error('Recipe not found', :not_found)
  end

  def recipe_params
    params.require(:recipe).permit(:title, :instructions, ingredients: [])
  end
end