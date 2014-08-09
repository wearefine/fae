Fae::Engine.routes.draw do

  root 'pages#home'

  devise_for :users, class_name: "Fae::User", module: :devise
  # as :user do
  #   get 'login' => 'devise/sessions#new', :as => :new_user_session
  #   post 'login' => 'devise/sessions#create', :as => :user_session
  #   get 'logout' => 'devise/sessions#destroy', :as => :destroy_user_session
  # end
  # resources :users


  # catch all 404
  match "*path" => 'pages#error404', via: [:get, :post]
end
