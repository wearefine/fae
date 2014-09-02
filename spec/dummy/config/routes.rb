Rails.application.routes.draw do
  root 'pages#home'

  namespace :admin do
    resources :releases
    resources :wines
  end
  mount Fae::Engine => "/admin"
end
