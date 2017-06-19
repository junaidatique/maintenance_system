Rails.application.routes.draw do
  
  resources :addl_logs
  resources :technical_orders do 
    resources :changes
  end
  resources :techlogs do 
    member do
      get 'create_addl_log'
      get 'create_limitation_log'
    end
  end
  resources :work_unit_codes do 
    collection do 
      get 'get_work_unit_codes'
    end
  end
  resources :flying_logs
  root 'users#index'
  resources :locations
  resources :aircrafts
  
  devise_for :users
  resources :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  devise_scope :user do
    root to: "devise/sessions#new"
  end
end
