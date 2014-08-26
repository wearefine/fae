Fae::Engine.routes.draw do

  resources :roles

  root 'pages#home'

  devise_for :users, class_name: "Fae::User", module: :devise, skip: [:sessions]
  as :user do
    get 'login' => '/devise/sessions#new', as: :new_user_session
    post 'login' => '/devise/sessions#create', as: :user_session
    get 'logout' => '/devise/sessions#destroy', as: :destroy_user_session
  end
  resources :users
  get 'settings' => 'users#settings', as: 'settings'

  # AJAX
  delete 'images/:id/delete_image' => 'images#delete_image', as: :delete_image
  get 'images/:id/crop_image' => 'images#crop_image', as: :crop_image
  patch 'images/:id/crop_image' => 'images#crop_image', as: :commit_crop

  post 'toggle/:object/:id/:attr', to: 'utilities#toggle', as: 'toggle'
  post 'sort/:object', to: 'utilities#sort', as: 'sort'


  # catch all 404
  match "*path" => 'pages#error404', via: [:get, :post]
end
