Rails.application.routes.draw do
  resources :transactions
  resources :members do
    member do
      get :wallet_transactions
    end
  end
  resources :network_commision_payments, only: [:index, :new, :create, :show]

  get 'home/index'
  get 'search', to: 'search#index'
  post 'search/results', to: 'search#results'
  get 'network_commisions/unpaid'

  devise_for :users

  devise_scope :user do
    authenticated :user do
      root 'home#index', as: :authenticated_root
    end

    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end

end