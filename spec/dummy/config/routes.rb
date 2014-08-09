Rails.application.routes.draw do
  root 'pages#home'

  mount Fae::Engine => "/admin"
end
