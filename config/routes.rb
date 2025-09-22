Rails.application.routes.draw do
  # Root route
  root "rails/health#show"
  
  namespace :api do
    namespace :v1 do
      resources :ingredients do
        collection do
          post :analyze_image
        end
      end
      
      resources :recipes do
        collection do
          post :generate
        end
      end
    end
  end

  # Reveal health status on /health that returns 200 if the app boots with no exceptions, otherwise 500.
  get "health" => "rails/health#show", as: :rails_health_check
end
