Rails.application.routes.draw do
  get 'posts/new'
  get 'health_check', to: 'application#health_check'

  post 'auth/login'
  post 'auth/logout'
  
  resources :groups, only: [:index, :create, :show, :update]

  resources :tags, only: [:index, :show, :create]

  resources :users, only: [:create, :show, :update, :destroy] do
    get 'tags', to: 'users#tags', on: :member
    get 'twitter_profile', to: 'users#twitter_profile', on: :member
  end
  resources :posts, only: [:show, :update, :destroy]
end
