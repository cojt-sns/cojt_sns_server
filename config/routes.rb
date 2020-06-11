Rails.application.routes.draw do
  get 'health_check', to: 'application#health_check'

  post 'auth/login'
  post 'auth/logout'
  
  resources :groups, only: [:index, :create, :show, :update]

  resources :tags, only: [:index, :show, :create]
end
