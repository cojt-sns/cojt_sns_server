Rails.application.routes.draw do
  get 'health_check', to: 'application#health_check'

  post 'auth/login'
  post 'auth/logout'
  get 'auth/user'
  
  resources :groups, only: [:index, :create, :show, :update] do
    get 'public/posts', to: 'posts#public_group', on: :member
    get 'posts', to: 'posts#group', on: :member
    post 'posts', to: 'posts#create', on: :member
    post 'join', to: 'posts#join', on: :member
    post 'leave', to: 'posts#leave', on: :member
  end

  resources :tags, only: [:index, :show, :create]

  resources :users, only: [:create, :show, :update, :destroy] do
    get 'tags', to: 'users#tags', on: :member
    get 'groups', to: 'users#groups', on: :member
    get 'twitter_profile', to: 'users#twitter_profile', on: :member
  end

  resources :posts, only: [:index, :show, :update, :destroy]

  mount ActionCable.server => '/cable'
end
