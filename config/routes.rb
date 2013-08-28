Wingolfsplattform::Application.routes.draw do 

  get "errors/unauthorized"

  mount Mercury::Engine => '/'

  get "map/show"

  get "angular_test", controller: "angular_test", action: "index"

  root :to => 'root#index'

  resources :posts
  resources :events  
  resources :bookmarks

  match "users/new/:alias" => "users#new"

  get :my_favorites, controller: "favorites", action: "index"

  resources :user_group_memberships
  resources :status_group_memberships

  resources :workflows

  resources :profile_fields
  resources :relationships

  mount WorkflowKit::Engine => "/workflow_kit", as: 'workflow_kit'

  match 'profile/:alias' => 'users#show', :as => :profile


  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match 'controllers/:controller(/:action(/:id))(.:format)'
     # TODO: remove this later
     # currently, there is a problem concerning the automated-generated boxes. they appear to require an 'edit' action for each
     # controller, which is defenetly not wanted.

  #match 'ajax/:controller(/:action(/:id))(.:format)', ajax: true

end

