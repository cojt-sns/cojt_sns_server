Rails.application.routes.draw do
  get 'health_check', to: 'application#health_check'

  post 'auth/login'
  post 'auth/logout'
  get 'auth/user'
  get '/auth/:provider/callback', to: 'auth#twitter_callback'
  
  resources :groups, only: [:index, :create, :show, :update] do
    get 'posts', to: 'posts#group', on: :member
    post 'posts', to: 'posts#create', on: :member
    post 'join', to: 'join', on: :member
    post 'leave', to: 'leave', on: :member
    get 'group_users', to: 'group_users#group', on: :member
    put 'group_users', to: 'group_users#update', on: :member
    get 'group_user', to: 'group_users#group_login_user', on: :member
  end

  resources :group_users, only: [:update, :show] do
    post 'authorization', to: 'authorization', on: :member
    post 'unauthorization', to: 'unauthorization', on: :member
  end

  resources :users, only: [:create, :show, :update, :destroy] do
    get 'tags', to: 'users#tags', on: :member
    get 'groups', to: 'users#groups', on: :member
    get 'twitter_profile', to: 'users#twitter_profile', on: :member
  end

  resources :posts, only: [:index, :show, :update, :destroy]

  mount ActionCable.server => '/cable'
end
