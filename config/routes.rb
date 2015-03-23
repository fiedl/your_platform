require 'sidekiq/web'

Rails.application.routes.draw do

  root :to => 'root#index'

  get :setup, to: 'setup#index'
  post :setup, to: 'setup#create'

  get :terms, to: 'terms_of_use#index'
  post :terms, to: 'terms_of_use#accept'

  # Users should be allowed to change their password(update registration), but not to sign up(create registration)
  devise_for :user_accounts, :controllers => {:sessions => 'sessions'}, :skip => [:registrations]
  devise_scope :user_account do
    match 'sign_in' => 'devise/sessions#new', as: :sign_in
    match 'sign_out' => 'devise/sessions#destroy', as: :sign_out
    get 'change_password' => 'devise/registrations#edit', :as => 'edit_registration'
    get 'change_password' => 'devise/registrations#edit', :as => 'edit_password'
    get 'change_password' => 'devise/registrations#edit', :as => 'change_password'
    get 'reset_password' => 'devise/passwords#edit', as: 'reset_password' # from email with token
    put 'change_password/:id' => 'devise/registrations#update', :as => 'registration' #todo: change to patch in rails 4.0
  end

  get 'search/guess', to: "search#lucky_guess"
  get 'search/preview', to: "search#preview"
  get :search, to: "search#index"

  mount Judge::Engine => '/judge'

  resources :users do
    get :autocomplete_title, on: :collection
    put :forgot_password, on: :member
    get :events, to: 'events#index'
    get :settings, to: 'user_settings#show'
    put :settings, to: 'user_settings#update'
  end
  get :settings, to: 'user_settings#index'

  resources :groups do
    get :mine, on: :collection, to: 'groups#index_mine'
    get 'events/public', to: 'events#index', published_on_local_website: true
    get :events, to: 'events#index'
    resources :posts
  end
  get :my_groups, to: 'groups#index_mine'
  
  
  get :corporations, to: 'corporations#index'
  resources :corporations, controller: 'groups'
  
  resources :pages
  
  resources :activities
    
  post :create_officers_group, to: 'officers#create_officers_group'

  resources :user_accounts
  resources :blog_posts
  resources :attachments do
    get 'description(.:format)', to: 'attachments#description'
  end
  resources :profile_fields  
  resources :workflows
  resources :user_group_memberships
  resources :status_group_memberships
  resources :relationships
  
  get 'events/public', to: 'events#index', published_on_global_website: true, all: true, as: 'public_events'
  resources :events do
    post :join, to: 'events#join'
    get :join, to: 'events#join_via_get', as: 'join_via_get'
    delete :leave, to: 'events#leave'
    post 'invite/:recipient', to: 'events#invite', as: 'invite'
  end
  
  put 'workflow_kit/workflows/:id/execute', to: 'workflows#execute'
  mount WorkflowKit::Engine => "/workflow_kit", as: 'workflow_kit'
  
  get :statistics, to: 'statistics#index', as: 'statistics_index'
  get "/statistics/:list", to: 'statistics#show', as: 'statistics'

  resources :bookmarks
  get :my_bookmarks, controller: "bookmarks", action: "index"
  
  get "errors/unauthorized"
  
  # Sidekiq Web UI
  sidekiq_constraint = lambda do |request|
    request.env['warden'].authenticate? && request.env['warden'].user.user.global_admin?
  end
  constraints sidekiq_constraint do
    mount Sidekiq::Web => '/sidekiq'
  end
  
  # Refile File Attachments
  mount Refile.app, at: '/refile', as: :refile_app
  
  get "/attachments/:id(/:version)/*basename.:extension", controller: 'attachments', action: 'download', as: 'attachment_download'
    
  get ':alias', to: 'users#show'
  
end
