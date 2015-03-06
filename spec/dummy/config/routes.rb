Rails.application.routes.draw do
  root 'pages#home'

  namespace :admin do
    resources :locations
    resources :releases
    resources :wines
    resources :varietals
    resources :acclaims
    resources :selling_points
    resources :events
    resources :people
    resources :aromas
    resources :teams do
      resources :coaches
      resources :players
    end
  end

  mount Fae::Engine => '/admin'
end
