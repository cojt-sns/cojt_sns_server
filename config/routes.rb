Rails.application.routes.draw do
  get 'health_check', to: 'application#health_check'

  post 'auth/login'
  post 'auth/logout'
  
  get 'groups/', to: 'groups#index'
  post '/groups', to: 'groups#create'

  get 'groups/:id', to: 'groups#show'
  put 'groups/:id', to: 'groups#update'
  resources :groups, only: [:index, :create, :show, :update]
end
