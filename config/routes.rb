Rocky::Application.routes.draw do
  
  root :to => "registrants#landing"
  match "/vr_to_pa_debug_ui.html", to: "application#vr_to_pa_debug_ui", via: :get
  match "/pdf_assistance_report", to: "application#pdf_assistance_report", via: :get, format: :csv
  match "/registrants/timeout", :to => "timeouts#index", :as=>'registrants_timeout', via: :get
  match "/registrants/new/:state_abbrev", to: "registrants#new", via: :get
  match "/registrants/map", to: "registrants#new", via: :get
  match "/registrants/map/:state_abbrev", to: "registrants#new", via: :get
  match "/share", to: "registrants#share", via: :get
  
  match "/state_registrants/:registrant_id/pending", to: "state_registrants#pending", as: "pending_state_registrant", via: :get
  match "/state_registrants/:registrant_id/complete", to: "state_registrants#complete", as: "complete_state_registrant", via: :get
  
  match "/state_registrants/:registrant_id/:step", to: "state_registrants#edit", as: "edit_state_registrant", via: :get
  match "/state_registrants/:registrant_id/:step", to: "state_registrants#update", as: "update_state_registrant", via: :patch

  
  
  resources "registrants", :only => [:new, :create, :show, :update] do
    resource "step_1", :controller => "step1", :only => [:show, :update]
    resource "step_2", :controller => "step2", :only => [:show, :update]
    resource "step_3", :controller => "step3", :only => [:show, :update]
    resource "step_4", :controller => "step4", :only => [:show, :update]
    resource "step_5", :controller => "step5", :only => [:show, :update]
    resource "download", :only => :show do
      member do
        get 'pdf'
        get 'pdf_assistance'
      end
    end
    resource "finish", :only => :show
    resource "ineligible", :only => [:show, :update]
    resources "tell_friends", :only => :create
    resource "state_online_registration", :only=>:show
    member do 
      get "stop_reminders", :to=>'reminders#stop', :as=>'stop_reminders'
    end
    collection do
      get 'new/:state_abbrev', action: 'new'
    end
    
  end

  resource  "partner_session"
  match  "login",  :to => "partner_sessions#new", :as=>'login', via: :get
  match "logout", :to => "partner_sessions#destroy", :as=>'logout', via: :get
  
  resource "partner", :path_names => {:new => "register", :edit => "profile"} do
    member do
      get "statistics"
      post "registrations"
      post "grommet_shift_report"
      get "download_csv"
      get "embed_codes"
    end
    resource "questions",     :only => [:edit, :update]
    resource "widget_image",  :only => [:show, :update]
    resource "logo",          :only => [:show, :update, :destroy]
    resource "branding", only: [:show, :update], controller: "branding" do
      collection do
        get 'css'
        get 'emails'
      end
      resource "approval", only: [:show, :update, :destroy], controller: "approval" do
        get "preview"
      end
    end
  end

  constraints Reg2DomainConstraint.new do
    get '/widget_loader.js', to: redirect('https://s3.amazonaws.com/ovr/widget_loader.js')
  end
  
  match "/widget_loader.js", :format => "js", :to => "registrants#widget_loader", :as=>'widget_loader', via: :get
  
  
  
  resources "password_resets", :only => [:new, :create, :edit, :update]

  resources "state_configurations", :only=>[:index, :show] do
    collection do
      post :submit
    end
  end
  
  resources "translations", :only=>[:index, :show] do
    collection do
      get :all_languages
    end
    member do
      post :submit
      get :preview_pdf
    end
  end

  namespace :api do
    namespace :v1 do
      resources :registrations, :only=>[:index, :create], :format=>'json'
      resource :state_requirements, :only=>:show, :format=>'json'
    end
    namespace :v2 do
      resources :registrations, :only=>[:index, :create], :format=>'json'
      resource :state_requirements, :only=>:show, :format=>'json'

      resources :partners, :only=>[:create], :format=>'json' do
        collection do
          get "partner", :action=>"show"
        end
      end
      
      resources :registration_states, :path=>'gregistrationstates', :as=>:gregistrationstates, :format=>'json', :only=>'index'      
      
      resources :partners, :path=>'partnerpublicprofiles', :only=>[], :format=>'json' do
        collection do
          get "partner", :action=>"show_public"
        end
      end
      match 'gregistrations',      :format => 'json', :controller => 'registrations', :action => 'index_gpartner', :via => :get
      match 'gregistrations',      :format => 'json', :controller => 'registrations', :action => 'create_finish_with_state', :via => :post
    end
    namespace :v3 do
      resources :registrations, :only=>[:index, :create], :format=>'json' do
        collection do
          get "pdf_ready", :action=>"pdf_ready"
          post "stop_reminders", :action=>"stop_reminders"
          post "bulk", :action=>"bulk"
        end
      end
      resource :state_requirements, :only=>:show, :format=>'json'

      resources :partners, :only=>[:show, :create], :format=>'json' do
        collection do
          get "partner", :action=>"show"
        end
      end
      
      resources :registration_states, :path=>'gregistrationstates', :as=>:gregistrationstates, :format=>'json', :only=>'index'      
      
      resources :partners, :path=>'partnerpublicprofiles', :only=>[], :format=>'json' do
        collection do
          get "partner", :action=>"show_public"
        end
      end
      match 'gregistrations',      :format => 'json', :controller => 'registrations', :action => 'index_gpartner', :via => :get
      match 'gregistrations',      :format => 'json', :controller => 'registrations', :action => 'create_finish_with_state', :via => :post
      match 'voterregistrationrequest', format: 'json', controller: 'registrations', action: 'create_pa', via: :post
      match 'clockIn', format: 'json', controller: 'registrations', action: 'clock_in', via: :post
      match 'clockOut', format: 'json', controller: 'registrations', action: 'clock_out', via: :post
      match 'partnerIdValidation', format: 'json', controller: 'partners', action: 'partner_id_validation', via: :get
    end
  end

  namespace :admin do
    root :controller => 'partners', :action => 'index'
    resource :grommet_queue, only: [:show],controller: "grommet_queue" do
      get :flush
      get :request_report, format: :csv
      patch :update_delay
    end
    resources :partners do
      member do
        get :regen_api_key
        get :impersonate
        post :publish
      end
      collection do 
        post :upload_registrant_statuses
      end
      resources :assets, :only => [ :index, :create, :destroy ]
    end
    resources :government_partners
    resource :partner_zips, :only=>[:create]
    resource :whitelabel, :only=>[], controller: "whitelabel" do
      member do
        get :requests
        post :approve_request
        post :reject_request
      end
    end
    resource  "admin_sessions"
    match  "login",  :to => "admin_sessions#new", :as=>'login', via: :get
    match "logout", :to => "admin_sessions#destroy", :as=>'logout', via: :get

    resource :stats, only: [] do
      get :downloads
    end
  end
    

end
