Rails.application.routes.draw do
  root 'pages#home'

  namespace :admin do
    resources :coaches
    resources :players
    resources :teams
    resources :locations
    resources :releases
    resources :wines
    resources :varietals
    resources :acclaims
    resources :selling_points
    resources :events
    resources :people
    resources :aromas
  end

  mount Fae::Engine => '/admin'
end
