Fae::Engine.routes.draw do

  root 'pages#home'


  # catch all 404
  match "*path" => 'pages#error404', via: [:get, :post]
end
