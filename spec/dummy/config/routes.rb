Rails.application.routes.draw do
  root 'pages#home'

  namespace :admin do
    resources :validation_testers
    resources :winemakers
    resources :cats
    resources :locations
    resources :releases do
      post 'filter', on: :collection
      get 'clone', on: :member
    end
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
