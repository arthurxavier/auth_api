Rails.application.routes.draw do
  resources :users, only: [ :create, :index, :destroy, :show ]
  post "login", to: "authentication#create"
end
