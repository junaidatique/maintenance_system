Rails.application.routes.draw do
  
  resources :flying_plans
  resources :non_flying_days
  resources :limitation_logs
  resources :addl_logs
  resources :technical_orders do 
    resources :changes
  end
  resources :techlogs do 
    member do
      get 'create_addl_log'
      get 'create_limitation_log'
      get 'create_techlog'
      get 'pdf'
    end
  end
  resources :work_unit_codes do 
    collection do 
      get 'get_work_unit_codes'
      get :autocomplete_codes
    end
  end
  resources :flying_logs do 
    member do
      get 'pdf'
    end
  end
  root 'flying_logs#index'
  resources :aircrafts  do 
    collection do 
      get 'get_aircrafts'
    end
  end
  
  devise_for :users, :skip => [:registrations]
  as :user do
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'    
    patch 'users' => 'devise/registrations#update', :as => 'user_registration'            
  end
  resources :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  devise_scope :user do
    root to: "devise/sessions#new"
  end
end
