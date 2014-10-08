Wingolfsplattform::Application.routes.draw do 

  resources :activities


  get "errors/unauthorized"

  # mount Mercury::Engine => '/'

  get "map/show"

  # get "angular_test", controller: "angular_test", action: "index"

  resources :posts

  match "users/new/:alias" => "users#new"

  put 'workflow_kit/workflows/:id/execute', to: 'workflows#execute'
  mount WorkflowKit::Engine => "/workflow_kit", as: 'workflow_kit'

  match 'profile/:alias' => 'users#show', :as => :profile
  
  # http://railscasts.com/episodes/53-handling-exceptions-revised
  match '(errors)/:status', to: 'errors#show', constraints: {status: /\d{3}/} # via: :all
  
  # See how all your routes lay out with "rake routes"

end

