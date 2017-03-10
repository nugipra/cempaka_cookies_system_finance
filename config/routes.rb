Rails.application.routes.draw do
  get 'wallet_transactions/index'

  get 'wallet_transactions/new'

  resources :transactions
  resources :members do
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