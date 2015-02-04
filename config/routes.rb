Fae::Engine.routes.draw do

  mount Judge::Engine => '/judge'

  root 'pages#home'

  devise_for :users, class_name: "Fae::User", module: :devise, skip: [:sessions]
  as :user do
    get 'login' => '/devise/sessions#new', as: :new_user_session
    post 'login' => '/devise/sessions#create', as: :user_session
    get 'logout' => '/devise/sessions#destroy', as: :destroy_user_session
  end
  resources :users

  get 'settings' => 'users#settings', as: 'settings'
  get 'help' => 'pages#help', as: 'help'

  # AJAX
  delete 'files/:id/delete_file' => 'files#delete_file', as: :delete_file
  delete 'images/:id/delete_image' => 'images#delete_image', as: :delete_image
  get 'images/:id/crop_image' => 'images#crop_image', as: :crop_image
  patch 'images/:id/crop_image' => 'images#crop_image', as: :commit_crop

  post 'toggle/:object/:id/:attr', to: 'utilities#toggle', as: 'toggle'
  post 'sort/:object', to: 'utilities#sort', as: 'sort'

  get '/root' => 'options#edit', as: :option
  match '/root' => 'options#update', via: [:put, :patch]

  get 'pages' => '/admin/content_blocks#index', as: 'static_pages'
  get 'content_blocks/:slug' => '/admin/content_blocks#edit', as: 'edit_content_block'
  match 'content_blocks/:slug/update' => '/admin/content_blocks#update', via: [:put, :patch], as: 'update_content_block'

  # catch all 404
  match "*path" => 'pages#error404', via: [:get, :post]
end
