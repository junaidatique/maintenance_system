Rails.application.routes.draw do
  
  resources :scheduled_inspections do 
    member do 
      get :apply_extention
      patch :save_extention
      get :cancel_extention
      get :create_techlog
      get :defer_inspection
      get :check_status
      get :restart_techlogs
    end    
  end
  resources :autherization_codes do 
    collection do 
      get 'get_codes'
      get :autocomplete_codes
      post :import
      get :upload
    end
  end
  # resources :scheduled_inspections
  resources :inspections do 
    resources :work_packages do
      collection do
        post :import
        get :upload        
      end
    end
  end
  resources :tools do
    collection do
      post :import
      get :autocomplete
      get :serail_autocomplete
    end
  end
  resources :reports do 
    collection do      
      get :airframe      
      get :airframe_pdf      
      get :inspection_record_pdf      
      get :inspection_pdf      
      get :tyre_record_pdf      
      get :history_pdf      
      get :techlog_pdf      
      
    end
  end
  resources :flying_plans
  resources :requested_tools
  resources :part_items
  resources :parts do
    collection do
      post :import
      get :upload
      get :autocomplete
      get :autocomplete_serial
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
      get 'approve_extension'
    end
  end
  resources :work_unit_codes do 
    collection do 
      get 'get_work_unit_codes'
      get :autocomplete_codes
      post :import
      get :upload
    end
  end
  resources :flying_logs do 
    member do
      get 'pdf'
      get 'cancel'
      get 'update_timing'
      get 'release'
      get 'get_history'
    end
  end
  root 'flying_logs#index'
  resources :aircrafts  do 
    collection do 
      get 'get_aircrafts'      
      get 'summary'      
      get 'report'      
    end
    member do 
      post :import
      get :upload
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
