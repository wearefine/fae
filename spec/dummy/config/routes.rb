Rails.application.routes.draw do
  root 'pages#home'

  namespace :admin do
    resources :jasaaas
    resources :jasaas
    resources :jasas
    resources :jaaaaaaaaaaaaaaas
    resources :jaaaaaaaaaaaaaas
    resources :jaaaaaaaaaaaaas
    resources :jaaaaaaaaaaaas
    resources :jaaaaaaaaaaas
    resources :jaaaaaaaaaas
    resources :jaaaaaaaaas
    resources :jaaaaaaaas
    resources :jaaaaaaas
    resources :jaaaaaas
    resources :jaaaaas
    resources :jaaaas
    resources :jaaas
    resources :jaas
    resources :jas
    resources :jasonaaaaaaaazzzs
    resources :jasonaaaaaaaazzs
    resources :jasonaaaaaaaazs
    resources :jasonaaaaaaaas
    resources :jasonaaaaaaas
    resources :jasonaaaaaas
    resources :jasonaaaaas
    resources :jasonaaaas
    resources :jasonaaas
    resources :jasonaas
    resources :jasonabaarzzaaaaaaaaaaaaas
    resources :jasonabaarzzaaaaaaaaaaaas
    resources :jasonabaarzzaaaaaaaaaaas
    resources :jasonabaarzzaaaaaaaaaas
    resources :jasonabaarzzaaaaaaaaas
    resources :jasonabaarzzaaaaaaaas
    resources :jasonabaarzzaaaaaaas
    resources :jasonabaarzzaaaaaas
    resources :jasonabaarzzaaaaas
    resources :jasonabaarzzaaaas
    resources :jasonabaarzzaaas
    resources :jasonabaarzzaas
    resources :jasonabaares
    resources :jasonas
    resources :jasons
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
