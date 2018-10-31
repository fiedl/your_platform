require 'sidekiq/web'

Rails.application.routes.draw do

  root :to => 'root#index'
  get :news, to: 'news#index'

  get :public, to: 'public_root#index', as: 'public_root'

  get :setup, to: 'setup#index'
  post :setup, to: 'setup#create'
  put :setup, to: 'setup#update'

  get :terms, to: 'terms_of_use#index'
  post :terms, to: 'terms_of_use#accept'

  get "vertical_navs/:navable_type/:navable_id", to: 'vertical_navs#show', as: :vertical_nav
  resources :nav_nodes

  # Users should be allowed to change their password(update registration), but not to sign up(create registration)
  devise_for :user_accounts, controllers: {sessions: "sessions", masquerades: 'user_account_masquerades'}, :skip => [:registrations]
  devise_scope :user_account do
    get 'sign_in' => 'sessions#new', as: :sign_in
    delete 'sign_out' => 'sessions#destroy', as: :sign_out
    get 'change_password' => 'devise/registrations#edit', :as => 'edit_registration'
    get 'change_password' => 'devise/registrations#edit', :as => 'edit_password'
    get 'change_password' => 'devise/registrations#edit', :as => 'change_password'
    get 'reset_password' => 'devise/passwords#edit', as: 'reset_password' # from email with token
    put 'change_password/:id' => 'devise/registrations#update', :as => 'registration' #todo: change to patch in rails 4.0
    get 'forgot-password', to: 'devise/passwords#new'
    get 'passwort-vergessen', to: 'devise/passwords#new'

    get "/auth/:provider/callback", to: 'sessions#create'
  end

  get 'search/guess', to: "search#lucky_guess"
  get 'search/preview', to: "search#preview"
  get :search, to: "search#index"
  get 'opensearch.xml', to: 'search#opensearch', as: 'opensearch'

  get "compact-nav-search(.:format)/(:query)", to: "compact_nav_search#show", as: 'compact_nav_search'

  mount Judge::Engine => '/judge'

  resources :users do
    put :forgot_password, on: :member
    resource :account, controller: 'user_accounts'
    get :events, to: 'events#index'
    get :profile, to: 'profiles#show'
    get :profile_fields, to: 'profile_fields#index'
    get :settings, to: 'user_settings#show'
    put :settings, to: 'user_settings#update'
    get :memberships, to: 'memberships#index'
    get :badges, to: 'user_badges#index'
    get :activities, to: 'activities#index'
    get :contact, to: 'user_contact_information#index', as: 'contact_information'
    get :posts, to: 'user_posts#index'
    get :sign_in, to: 'user_masquerade#show', as: 'masquerade'
    post :renew_cache, to: 'cache_renewals#create'
  end

  get :settings, to: 'user_settings#index'
  get 'settings/app', to: 'app_settings#index', as: 'app_settings'
  resources :settings, as: 'rails_settings_scoped_setting'
  resources :settings, as: 'setting'

  get :authorized_users, to: 'authorized_users#index'

  get 'groups/:id/address_labels/(:filter)/:pdf_type.:format', to: 'groups#show', as: 'group_address_labels'
  #get 'groups/:parent_group_id/subgroups(.:format)', to: 'groups#index', as: 'subgroups'
  resources :groups do
    get :news, to: 'group_news#index'
    get :subgroups, to: 'groups#index'
    get :mine, on: :collection, to: 'groups#index_mine'
    get 'events/public', to: 'events#index', published_on_local_website: true
    get :events, to: 'events#index'
    resources :semester_calendars
    get :semester_calendar, to: 'semester_calendars#show', as: 'search_semester_calendar'
    resources :posts
    get :pages, to: 'group_pages#index'
    get :profile, to: 'profiles#show'
    get :profile_fields, to: 'profile_fields#index'
    get :members, to: 'group_members#index'
    post 'members/memberships', to: 'memberships/from_members_index#create'
    get :member_data_summaries, to: 'group_member_data_summaries#index'
    get :officers, to: 'officers#index'
    get :settings, to: 'group_settings#index'
    get :mailing_lists, to: 'group_mailing_lists#index'
    get :memberships, to: 'memberships#index'
    get :workflows, to: 'workflows#index'
    post :test_welcome_message, to: 'groups#test_welcome_message'
    get :term_report, to: 'term_reports#show'
    get 'terms/:year/:term_type/report', to: 'term_reports#show'
    get 'terms/:year/:term_type/calendar', to: 'semester_calendars#show', as: 'semester_calendar_by_term_and_year'
    get 'exports/:list.:format', to: 'list_exports#show', as: 'list_export'
    post :renew_cache, to: 'cache_renewals#create'
    namespace :excel_imports do
      resources :users
    end
  end
  get :my_groups, to: 'groups#index_mine'

  namespace :groups, path: "" do
    resources :groups_of_groups do
      get 'exports/table.:format', to: 'groups_of_groups/table_exports#show', as: 'table_export'
    end
    resources :corporations_parents, controller: 'groups_of_groups'
  end

  get :corporations, to: 'corporations#index'
  resources :corporations, controller: 'groups'
  resources :officer_groups

  namespace :officers do
    get ':flag', to: 'by_flag#index'
  end

  resources :members, only: [:index], controller: :members_dashboard

  resources :pages do
    get :photo_contest, to: 'photo_contests#show'
    get :activities, to: 'activities#index'
    get :settings, to: 'page_settings#index'
    get :attachments, to: 'attachments#index'
    get :permalinks, to: 'permalinks#index'
    get :settings, to: 'page_settings#index'
    resources :publications, only: [:create], controller: :page_publications
    post :renew_cache, to: 'cache_renewals#create'
    get :renew_cache, to: 'cache_renewals#create'
    resources :logos, controller: :logos
    resources :relocations, controller: 'page_relocations'
  end

  get :home_pages, to: 'pages/home_pages#index'
  post :home_pages, to: 'pages/home_pages#create'

  resources :logos

  resources :mailing_lists
  get :lists, to: 'mailing_lists#index'

  namespace :structureables do
    delete 'sub_entries/destroy', to: 'sub_entries#destroy'
    namespace :sub_entries do
      resources :existing_groups
      resources :pages
      resources :groups
    end
  end

  resources :projects

  namespace :activities do
    get :exports, to: 'exports#index'
    #get :addresses, to: 'addresses#index'
    get :charts, to: redirect('/charts/activities')
  end
  resources :activities
  resources :requests

  namespace :charts do
    get :activities, to: 'activities#index'
    get 'activities/per_corporation_and_time', to: 'activities#per_corporation_and_time'
    get :term_reports, to: 'term_reports#index'
    get 'term_reports/members/per_corporation_and_term', to: 'term_reports/members#per_corporation_and_term'
  end

  resources :term_reports do
    post :submit, to: 'term_report_submissions#create'
    post :accept, to: 'term_report_acceptions#create'
    post :recalculate, to: 'term_report_recalculations#create'
    get :export, to: 'term_reports/exports#show', on: :collection
  end

  get :term_report, to: 'term_reports#show', as: :search_term_report

  get :scores, to: 'corporation_scores#index', as: :corporation_scores

  post :create_officers_group, to: 'officers#create_officers_group'

  resources :blogs do
    delete :subscriptions, to: 'blog_subscriptions#destroy'
    resources :subscriptions, controller: 'blog_subscriptions'
  end
  get 'confirm_blog_subscription/:token', to: 'blog_subscription_confirmations#create', as: :create_blog_subscription_confirmation
  resources :blog_posts
  resources :attachments do
    get 'description(.:format)', to: 'attachment_descriptions#show'
  end
  resources :profile_fields
  resources :memberships
  resources :status_memberships
  resources :relationships

  get 'events/public', to: 'events#index', published_on_global_website: true, all: true, as: 'public_events'
  resources :events do
    post :join, to: 'events#join'
    get :join, to: 'events#join_via_get', as: 'join_via_get'
    delete :leave, to: 'events#leave'
    post 'invite/:recipient', to: 'events#invite', as: 'invite'
    get :attachments, to: 'attachments#index'
    post :renew_cache, to: 'cache_renewals#create'
  end
  resources :semester_calendars do
    member do
      patch :update_term_and_year, to: 'semester_calendars#update_term_and_year'
    end
  end

  get 'posts/preview', to: 'posts#preview', as: 'post_preview'
  resources :posts do
    get :deliveries, to: 'post_deliveries#index'
    put :deliver, to: 'posts#deliver'
    get :attachments, to: 'attachments#index'
  end
  resources :comments

  patch 'notifications/read_all', to: 'notifications#read_all', as: 'read_all_notifications'
  resources :notifications

  resources :issues

  post :support_requests, to: 'support_requests#create'

  get 'avatars', to: 'avatars#show'
  get 'emojis', to: 'emojis#index'

  resources :badges, controller: 'user_badges'

  get :statistics, to: 'statistics#index', as: 'statistics_index'
  get "/statistics/:list", to: 'statistics#show', as: 'statistics'

  resources :bookmarks
  get :my_bookmarks, controller: "bookmarks", action: "index"

  resources :workflows do
    put 'execute', on: :member
  end
  put 'workflow_kit/workflows/:id/execute', to: 'workflows#execute'
  put 'users/:user_id/status_workflows/:id/execute(.:format)', to: 'workflows/status_workflows#execute', as: 'execute_status_workflow'

  namespace :decision_making do
    resources :federal_ballots
    resources :ballots do
      resources :signatures
      resources :submissions
    end
  end

  resources :features

  resources :integrations, only: [:index]
  get 'integrations/trello', to: 'integrations/trello#show'


  get :renew_cache, to: 'cache_renewals#create'

  get "errors/unauthorized"

  # Dashboards for global admins:
  global_admin_constraint = lambda do |request|
    request.env['warden'].authenticate? && request.env['warden'].user.user.global_admin?
  end
  developer_constraint = lambda do |request|
    request.env['warden'].authenticate? && (request.env['warden'].user.user.developer? || request.env['warden'].user.user.global_admin?)
  end
  constraints global_admin_constraint do
    mount Sidekiq::Web => '/sidekiq'
  end

  # Refile File Attachments
  mount Refile.app, at: '/refile', as: :refile_app

  get 'tags/:tag_name', to: 'tags#show', as: :tag
  resources :tags
  resources :tags, path: :acts_as_taggable_on_tags, as: :acts_as_taggable_on_tags

  resources :contact_messages, only: [:new, :create]

  # Email previews
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  get :feeds, to: 'feeds#index', as: :feeds

  # ATTENTION: Changing feed urls might break subscribed feeds!
  get 'feeds/:id(.:format)', to: 'feeds#show', as: :feed

  resources :beta_invitations
  resources :betas do
    get :invitations, to: 'beta_invitations#index'
  end

  namespace :mobile do
    get :welcome, to: 'welcome#index'
    get :beta, to: 'beta#show'
    get :dashboard, to: 'dashboard#index'
    get :app_info, to: 'app_info#index'
    get :contacts, to: 'contacts#index'
    get :documents, to: 'documents#index'
    get 'documents/:id', to: 'documents#show', as: 'document'
    get 'events/:id', to: 'events#show', as: 'event'
    get :nearby_locations, to: 'nearby_locations#index'
    get 'partials/:partial_key', to: 'partials#show'
    resources :photos, only: [:show, :index, :create]
  end


  apipie
  get :api, to: 'apipie/apipies#index'
  namespace :api do
    namespace :v1 do
      mount_devise_token_auth_for 'UserAccount', at: 'auth', controllers: {
        sessions: 'api/v1/sessions'
      }
      get :sso, to: 'single_sign_on#sign_in'
      namespace :public do
        resources :groups do
          resources :events
        end
        resources :events
        resources :blog_posts
      end
      resources :users do
        get :corporate_vita, to: 'users/corporate_vita#show'
        get :change_status_button, to: 'users/change_status_button#show'
        get :titles, on: :collection, to: 'users/titles#index'
        get :avatar, to: '/avatars#show'
        post :location, on: :collection, to: 'users/locations#create'
        put :location, on: :collection, to: 'users/locations#update'
      end
      get :current_user, to: 'current_user#show'
      get :current_role, to: 'current_role#show'
      resources :memberships
      namespace :navables do
        put :vertical_nav_configuration, to: 'vertical_nav_configuration#update'
      end
      get :search_groups, to: 'search_groups#index'
      get :search_pages, to: 'search_pages#index'
      get :navigation, to: 'navigation#show'
      get 'search/preview', to: '/search#preview', defaults: {format: :json}
    end
  end


  get "/attachments/:id(/:version)/*basename.:extension", controller: 'attachment_downloads', action: 'show', as: 'attachment_download'

  # We need 'show' for short permalinks and 'put' to make best_in_place work,
  # which does not distinguish when generating the url.
  # https://github.com/bernat/best_in_place/blob/master/lib/best_in_place/helper.rb
  #
  {get: 'show', put: 'update'}.each do |http_method, controller_method|
    send http_method, '*permalink', to: "tags##{controller_method}", constraints: lambda { |request| Permalink.for_host(request.host).where(reference_type: 'ActsAsTaggableOn::Tag', url_path: request[:permalink]).any? }
    send http_method, '*permalink', to: "blogs##{controller_method}", constraints: lambda { |request| Permalink.for_host(request.host).where(reference_type: 'Page', url_path: request[:permalink]).first.try(:reference).kind_of?(Blog) }
    send http_method, '*permalink', to: "blog_posts##{controller_method}", constraints: lambda { |request| Permalink.for_host(request.host).where(reference_type: 'Page', url_path: request[:permalink]).first.try(:reference).kind_of?(BlogPost) }
    send http_method, '*permalink', to: "pages##{controller_method}", constraints: lambda { |request| Permalink.for_host(request.host).where(reference_type: 'Page', url_path: request[:permalink]).any? }
    send http_method, '*permalink', to: "groups##{controller_method}", constraints: lambda { |request| Permalink.for_host(request.host).where(reference_type: 'Group', url_path: request[:permalink]).any? }
  end
  get ':alias', to: 'users#show', constraints: lambda { |request| User.where(alias: request[:alias]).any? }

end
