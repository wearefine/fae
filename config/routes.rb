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
  get 'publish' => 'publish#index', as: 'publish'
  get 'help' => 'pages#help', as: 'help'
  get 'activity' => 'pages#activity_log', as: 'activity_log'
  post 'activity/filter' => 'pages#activity_log_filter', as: 'activity_log_filter'

  get 'first_user' => 'setup#first_user'
  post 'first_user' => 'setup#create_first_user'

  # AJAX
  delete 'files/:id/delete_file' => 'files#delete_file', as: :delete_file
  delete 'images/:id/delete_image' => 'images#delete_image', as: :delete_image

  post 'toggle/:object/:id/:attr', to: 'utilities#toggle', as: 'toggle'
  post 'sort/:object', to: 'utilities#sort', as: 'sort'
  post 'language_preference/:language', to: 'utilities#language_preference'
  post 'search/:query', to: 'utilities#global_search'
  post 'search', to: 'utilities#global_search'
  post 'html_embedded_image', to: 'images#create_html_embedded'

  get '/root' => 'options#edit', as: :option
  match '/root' => 'options#update', via: [:put, :patch]

  get 'pages' => '/admin/content_blocks#index', as: 'pages'
  get 'content_blocks/:slug' => '/admin/content_blocks#edit', as: 'edit_content_block'
  match 'content_blocks/:slug/update' => '/admin/content_blocks#update', via: [:put, :patch], as: 'update_content_block'

  get 'form_managers/fields' => 'form_managers#fields', as: 'form_managers_fields'
  post 'form_managers/update' => 'form_managers#update', as: 'form_managers_update'

  get 'publish/deploys_list' => 'publish#deploys_list', as: 'publish_deploys_list'
  get 'publish/changes_list' => 'publish#changes_list', as: 'publish_changes_list'
  post 'publish/publish_site' => 'publish#publish_site', as: 'publish_publish_site'

  # catch all 404
  match "*path" => 'pages#error404', via: [:get, :post]

end
