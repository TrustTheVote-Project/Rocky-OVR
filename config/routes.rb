Rails.application.routes.draw do
    
  root :to => "registrants#landing"
  get "/registrants/new/sitemap.xml", to: redirect("https://register.rockthevote.com/sitemap.xml")
  get "/registrants/new/robots.txt", to: redirect("https://register.rockthevote.com/robots.txt")

  match "/vr_to_pa_debug_ui.html", to: "application#vr_to_pa_debug_ui", via: :get
  match "/registrants/timeout", :to => "timeouts#index", :as=>'registrants_timeout', via: :get
  match "/registrants/new/:state_abbrev", to: "registrants#new", via: :get
  match "/registrants/map", to: "registrants#new", via: :get
  match "/registrants/map/:state_abbrev", to: "registrants#new", via: :get
  match "/absentee", to: "abrs#new", via: :get
  match "/lookup", to: "catalist_lookups#new", via: :get
  match "/trackballot", to: "ballot_status_checks#new", via: :get
  match "/trackballot/:zip", to: "ballot_status_checks#zip", via: :get, as: :ballot_status_check_zip
  match "/share", to: "registrants#share", via: :get
  get "/share/:partner_id", to: "registrants#share_no_reg", as: :share_no_reg


  match "/register", to: "registrants#landing", via: :get
  match "/register-to-vote", to: "registrants#landing", via: :get
  match "/am-i-registered-to-vote", to: "catalist_lookups#new", via: :get
  match "/absentee-ballot", to: "abrs#new", via: :get

  match "/state_registrants/:registrant_id/pending", to: "state_registrants#pending", as: "pending_state_registrant", via: :get
  match "/state_registrants/:registrant_id/skip_state_flow", to: "state_registrants#skip_state_flow", as: "skip_state_flow_registrant", via: :get
  match "/state_registrants/:registrant_id/complete", to: "state_registrants#complete", as: "complete_state_registrant", via: :get
  
  match "/state_registrants/:registrant_id/:step", to: "state_registrants#edit", as: "edit_state_registrant", via: :get
  match "/state_registrants/:registrant_id/:step", to: "state_registrants#update", as: "update_state_registrant", via: :patch

  match "/get-bounce-notification", to: "ses#bounce", via: [:get, :post]

  get ":path/sitemap.xml", to: redirect("https://register.rockthevote.com/sitemap.xml")
  get "(*path)/robots.txt", to: redirect("https://register.rockthevote.com/robots.txt")
  
  resource :canvassing_shifts, path: "shift" do
    member do
      get 'end_shift'
      get 'set_partner'
    end
  end

  resources "trackballot", only: [:new, :create], controller: "ballot_status_checks", as: :ballot_status_checks
  
  match "/absentee/timeout", :to => "abr_timeouts#index", :as=>'abr_timeout', via: :get
  
  resources "lookup", :only => [:new, :create, :show, :update], :controller=>"catalist_lookups", as: :catalist_lookups do
    member do
      get "registration"
      get "abr"
    end
  end

  resources "absentee", :only => [:new, :create, :show, :update], :controller=>"abrs", as: :abrs do
    member do
      get "step_2"
      get "registered"
      get "step_3"
      get "not_registered"
      get "registration"
      get "preparing"
      get "download"
      get "finish"
      get "state_online"
      get "state_online_redirect"

      post "track_view", format: :json
    end
  end

  resources 'pledge', only: [:new, :create, :show], controller: 'alert_requests', as: :alert_requests
  match "/pledge", to: "alert_requests#new", via: :get
  
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
      post "track_view", format: :json
    end
    collection do
      get 'new/:state_abbrev', action: 'new'
    end
    
  end

  resource  "user_session"
  match  "login",  :to => "user_sessions#new", :as=>'login', via: :get
  match "logout", :to => "user_sessions#destroy", :as=>'logout', via: :get
  
  resource "user", path_names: {:new => "register", :edit => "profile"} do
  end
  # MFA for user accounts
  resources :mfa_sessions, only: [:new, :create]

  resources "partners", :path_names => {:new => "register"} do
    member do
      get "statistics"
      post "registrations"
      post "canvassing_shift_report"
      post "grommet_registrant_report"
      post "grommet_shift_report"
      post "abr_report"
      post "lookup_report"
      post "alert_request_report"
      get "reports"      
      get "download_csv"
      get "embed_codes"
    end
    resources "partner_users", only: [:index, :create, :destroy]
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
  resources :admin_password_resets, :only => [ :new, :create, :edit, :update ]

  resources "state_configurations", :only=>[:index, :show] do
    collection do
      post :submit
    end
  end
  
  resources "translations", :only=>[:index, :show] do
    collection do
      get :all_languages
      get :export
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
    namespace :v4 do
      resources :registrations, :only=>[:create], :format=>'json' do
        collection do
          get "pdf_ready", :action=>"pdf_ready"
          post "stop_reminders", :action=>"stop_reminders"
          post "bulk", :action=>"bulk"
        end
      end
      resources :registrant_reports, :only=>[:create, :show], :format=>'json' do
        member do
          get "download", action: :download
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
      match 'gregistrations',      :format => 'json', :controller => 'registrations', :action => 'create_finish_with_state', :via => :post
      match 'gregistrant_reports', :format => 'json', :controller => 'registrant_reports', :action => 'gcreate', :via => :post
      match 'gregistrant_reports/:id', :format => 'json', :controller => 'registrant_reports', :action => 'gshow', :via => :get, as: 'gregistrant_report'
      match 'gregistrant_reports/:id/download', :format => 'json', :controller => 'registrant_reports', :action => 'gdownload', :via => :get, as: 'download_gregistrant_report'
      
      match 'validateVersion', format: 'json', controller: 'partners', action: 'validate_version', via: :get
      match 'partnerIdValidation', format: 'json', controller: 'partners', action: 'partner_id_validation', via: :get
      
      match 'voterregistrationrequest', format: 'json', controller: 'registrations', action: 'create_pa', via: :post
      resources :canvassing_shifts, only: [:create, :update] do
        collection do
          put :update
        end
        member do
          get :complete
        end
      end
      match "completeShift/:id/complete", to: "canvassing_shifts#complete", via: :get
      
    end

    namespace :v5 do
      resources :registrations, :only=>[:create], :format=>'json' do
        collection do
          get "pdf_ready", :action=>"pdf_ready"
          post "stop_reminders", :action=>"stop_reminders"
          post "bulk", :action=>"bulk"
        end
      end
      resources :registrant_reports, :only=>[:create, :show], :format=>'json' do
        member do
          get "download", action: :download
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
      match 'gregistrations',      :format => 'json', :controller => 'registrations', :action => 'create_finish_with_state', :via => :post
      match 'gregistrant_reports', :format => 'json', :controller => 'registrant_reports', :action => 'gcreate', :via => :post
      match 'gregistrant_reports/:id', :format => 'json', :controller => 'registrant_reports', :action => 'gshow', :via => :get, as: 'gregistrant_report'
      match 'gregistrant_reports/:id/download', :format => 'json', :controller => 'registrant_reports', :action => 'gdownload', :via => :get, as: 'download_gregistrant_report'
      
      match 'validateVersion', format: 'json', controller: 'partners', action: 'validate_version', via: :get
      match 'partnerIdValidation', format: 'json', controller: 'partners', action: 'partner_id_validation', via: :get
      
      match 'voterregistrationrequest/pa', format: 'json', controller: 'registrations', action: 'create_pa', via: :post
      match 'voterregistrationrequest/mi', format: 'json', controller: 'registrations', action: 'create_mi', via: :post
      resources :canvassing_shifts, only: [:create, :update] do
        collection do
          put :update
        end
        member do
          get :complete
        end
      end
      match "completeShift/:id/complete", to: "canvassing_shifts#complete", via: :get
      
    end

  end

  namespace :admin do
    resources :mfa_sessions, only: [:new, :create]
    root :controller => 'partners', :action => 'index'
    resource :grommet_queue, only: [:show],controller: "grommet_queue" do
      get :flush
      get :request_report, format: :csv
      patch :update_delay
    end
    resources :users, except: [:show] do
      member do
        get :impersonate
        get :deactivate
        get :reactivate
        get :resetmfa
      end
    end
    resources :emails, except: [:new, :edit, :show ]
    resources :ab_tests, only: [:index, :show ]
    resources :domains, except: [:new, :edit, :show, :index]
    resources :geo_states, only: [:index, :edit, :update, :show] do
      collection do 
        post :bulk_update
      end
      member do
        get :zip_codes
        get :check_zip_code
        get :remove_direct_mail_partner_id
      end
    end
    resources :request_logs, only: [:index, :show]
    resources :blocks_submissions, only: [:index]
    resources :pdf_delivery_reports, only: [:index] do
      collection do 
        get :create_report
      end
      member do
        get :download
      end
    end
    
    resources :partners do
      member do
        get :regen_api_key
        post :add_user
        post :publish
        delete :remove_user
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
    match 'reset_admin_passwords', to: "base#reset_admin_passwords", as: 'reset_admin_passwords', via: :get
    match  "login",  :to => "admin_sessions#new", :as=>'login', via: :get
    match "logout", :to => "admin_sessions#destroy", :as=>'logout', via: :get

    resource :stats, only: [] do
      get :downloads
    end
  end
    

end
