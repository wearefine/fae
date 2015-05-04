Rails.application.routes.draw do
  root 'pages#home'

  namespace :admin do
    post ':controller/filter', action: 'filter'
    resources :locations
    resources :releases do
      post '/releases/filter', action: 'filter'
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
