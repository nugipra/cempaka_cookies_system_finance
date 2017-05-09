Rails.application.routes.draw do
  get 'wallet_transactions/index'

  get 'wallet_transactions/new'

  resources :transactions
  resources :members do
    member do
      get :network_commisions
      get :web_development_commisions
      get :add_registration_quota
      post :process_add_registration_quota
      get :upgrade
      patch :process_upgrade
    end
    member do
      resources :wallet_transactions, only: [:index, :new, :create] do
        collection do
          get :verify
          patch :do_verify
        end
      end
    end
  end
  resources :network_commision_payments, only: [:index, :new, :create, :show]

  get 'home/index'
  get 'search', to: 'search#index'
  post 'search/results', to: 'search#results'
  get 'search/results', to: 'search#results'
  get 'network_commisions/unpaid'

  devise_for :members

  devise_scope :member do
    authenticated :member do
      root 'home#index', as: :authenticated_root
    end

    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
    end

    delete "logout", to: "devise/sessions#destroy", as: :logout
  end

  resource :member, only: [:edit] do
    collection do
      get "change_password"
      patch "update_password"
      get "wallet_history"
    end
  end

end