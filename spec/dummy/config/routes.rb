Rails.application.routes.draw do
  root 'pages#home'

  namespace :admin do
    resources :beers
    resources :article_categories
    resources :articles
    resources :release_notes
    resources :milestones
    resources :validation_testers
    resources :winemakers
    resources :cats
    resources :locations
    resources :releases do
      post 'filter', on: :collection
    end
    resources :legacy_releases do
      post 'filter', on: :collection
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
      resources :jerseys
    end
  end

  mount Fae::Engine => '/admin'
end
