Rails.application.routes.draw do
  get 'health_check', to: 'application#health_check'

  post 'auth/login'
  post 'auth/logout'
end
