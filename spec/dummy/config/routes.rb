Rails.application.routes.draw do
  root 'pages#home'

  namespace :admin do
    resources :releases
    resources :wines
    resources :varietals
    resources :selling_points
  end
  mount Fae::Engine => "/admin"
end
