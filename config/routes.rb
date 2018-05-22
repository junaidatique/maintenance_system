Rails.application.routes.draw do
  
  resources :tools do
    collection do
      post :import
      get :autocomplete
    end
  end
  resources :flying_plans
  resources :parts do
    collection do
      post :import
      get :upload
      get :autocomplete
    end
  end
  resources :non_flying_days
  resources :limitation_logs do 
    member do
      get 'pdf'
    end
  end
  resources :addl_logs do 
    member do
      get 'pdf'
    end
  end
  resources :technical_orders do 
    collection do      
      get :history      
    end
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

  mount ActionCable.server => '/cable'

end
