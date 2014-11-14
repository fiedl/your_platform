Rails.application.routes.draw do
  
  root :to => 'root#index'
  get :setup, to: 'setup#index'
  post :setup, to: 'setup#create'
  
  get :terms, to: 'terms_of_use#index'
  post :terms, to: 'terms_of_use#accept'
  
  devise_for :user_accounts, :controllers => {:sessions => 'sessions'}
  devise_scope :user_account do
    match 'sign_in' => 'sessions#new', as: :sign_in
    match 'sign_out' => 'sessions#destroy', as: :sign_out
  end
  
  get 'search/guess', to: "search#lucky_guess"
  get :search, to: "search#index"

  resources :users do
    get :autocomplete_title, on: :collection
    put :forgot_password, on: :member
    get :events, to: 'events#index'
  end

  resources :groups do
    get :mine, on: :collection, to: 'groups#index_mine'
    get 'events/public', to: 'events#index', published_on_local_website: true
    get :events, to: 'events#index'
    resources :posts
  end
  get :my_groups, to: 'groups#index_mine'
  
  resources :pages
  
  post :create_officers_group, to: 'officers#create_officers_group'

  resources :user_accounts
  resources :blog_posts
  resources :attachments
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
  
  get :statistics, to: 'statistics#index'

  resources :bookmarks
  get :my_bookmarks, controller: "bookmarks", action: "index"
  
  get "/attachments/:id(/:version)/*basename.:extension", controller: 'attachments', action: 'download', as: 'attachment_download'
    
  get ':alias', to: 'users#show'
  
end
