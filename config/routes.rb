Fae::Engine.routes.draw do

  mount Judge::Engine => '/judge'

  root 'pages#home'

  devise_for :users, class_name: "Fae::User", module: :devise, skip: [:sessions]
  
  as :user do
    get 'login' => 'sessions#new', as: :new_user_session
    post 'login' => 'sessions#create', as: :user_session
    get 'logout' => 'sessions#destroy', as: :destroy_user_session
  end
  resources :deploy_hooks
  resources :flex_components
  resource :two_factor_settings, except: [:index, :show]
  resources :site_deploy_hooks
  resources :sites
  resources :users
  post 'alt_texts/:id/update_alt' => 'alt_texts#update_alt'
  get 'alt_texts' => 'alt_texts#index', as: 'alt_texts'
  post 'alt_texts/filter' => 'alt_texts#filter', as: 'alt_texts_filter'
  resources :flex_components

  get 'settings' => 'users#settings', as: 'settings'
  get 'deploy' => 'deploy#index', as: 'deploy'
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
  post 'translate_text', to: 'utilities#translate_text'
  post 'generate_alt', to: 'utilities#generate_alt'

  get '/root' => 'options#edit', as: :option
  match '/root' => 'options#update', via: [:put, :patch]

  get 'pages' => '/admin/content_blocks#index', as: 'pages'
  get 'content_blocks/:slug' => '/admin/content_blocks#edit', as: 'edit_content_block'
  match 'content_blocks/:slug/update' => '/admin/content_blocks#update', via: [:put, :patch], as: 'update_content_block'

  get 'form_managers/fields' => 'form_managers#fields', as: 'form_managers_fields'
  post 'form_managers/update' => 'form_managers#update', as: 'form_managers_update'

  get 'deploy/deploys_list' => 'deploy#deploys_list', as: 'deploy_deploys_list'
  post 'deploy/deploy_site' => 'deploy#deploy_site', as: 'deploy_deploy_site'

  ## catch all 404
  match "*path" => 'pages#error404', via: [:get, :post]

end
