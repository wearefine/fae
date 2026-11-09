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
  resource :two_factor_settings, except: [:show]
  resources :site_deploy_hooks
  resources :sites
  resources :users
  post 'alt_texts/:id/update_alt' => 'alt_texts#update_alt'
  get 'alt_texts' => 'alt_texts#index', as: 'alt_texts'
  post 'alt_texts/filter' => 'alt_texts#filter', as: 'alt_texts_filter'

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
  delete 'videos/:id/delete_video' => 'videos#delete_video', as: :delete_video
  post 'videos/create_upload' => 'videos#create_upload', as: :create_video_upload
  post 'videos/:id/attach_upload' => 'videos#attach_upload', as: :attach_video_upload
  post 'videos/attach_new_upload' => 'videos#attach_new_upload', as: :attach_new_video_upload
  get 'videos/upload_status' => 'videos#upload_status', as: :video_upload_status
  get 'videos/:id/status' => 'videos#status', as: :video_status

  # Mux webhooks (signature verified, no session)
  post 'mux/webhook' => 'mux_webhooks#create', as: :mux_webhook

  post 'toggle/:object/:id/:attr', to: 'utilities#toggle', as: 'toggle'
  post 'sort/:object', to: 'utilities#sort', as: 'sort'
  post 'ranked_item', to: 'utilities#ranked_item', as: 'ranked_item'
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
