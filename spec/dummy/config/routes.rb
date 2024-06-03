Rails.application.routes.draw do
  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/api"
  post "/api", to: "graphql#execute"
  root 'pages#home'

  namespace :admin do
    resources :sub_spirits
    resources :spirits
    resources :hero_componentttttts
    resources :hero_componenttttts
    resources :hero_componentttts
    resources :hero_componenttts
    resources :hero_componentts
    resources :hero_components
    resources :hero_components
    resources :flex_components
    resources :flex_components
    resources :flex_components
    resources :text_components
    resources :sub_aromas
    resources :poly_things
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
    resources :wines
    resources :varietals
    resources :acclaims
    resources :selling_points
    resources :events
    resources :people
    resources :aromas
    resources :teams do
      post 'filter', on: :collection
      resources :coaches
      resources :players
      resources :jerseys
    end
  end

  mount Fae::Engine => '/admin'
end
