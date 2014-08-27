Rails.application.routes.draw do
  root 'pages#home'

  namespace :admin do
    resources :releases
  end
  mount Fae::Engine => "/admin"
end
