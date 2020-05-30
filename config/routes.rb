Rails.application.routes.draw do
  get 'health_check', to: 'application#health_check'
end
