Rails.application.routes.draw do

  devise_for :user_accounts, :controllers => {:sessions => 'sessions'}
  devise_scope :user_account do
    match 'sign_in' => 'devise/sessions#new', as: :sign_in
    match 'sign_out' => 'devise/sessions#destroy', as: :sign_out
  end

  resources :user_accounts
  resources :pages 
  resources :attachments
  
  get ':alias', to: 'users#show'
  
end
