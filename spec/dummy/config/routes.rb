Rails.application.routes.draw do
  namespace :admin do
    resources :releases
  end

  root 'pages#home'

  mount Fae::Engine => "/admin"
end
