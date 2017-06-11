Rails.application.routes.draw do
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
