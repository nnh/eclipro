Rails.application.routes.draw do
  # resources :sections
  resources :protocols do
    resources :participations, only: [:new, :create, :destroy]

    resources :contents, only: [:show, :update] do
      resources :images, only: [:create, :show]

      member do
        get :history, :compare, :revert
        put :change_status
      end

      resources :comments, only: [:index, :create] do
        member do
          put :resolve
        end
        collection do
          get :reply
        end
      end
    end

    member do
      get :clone, :export, :finalize, :reinstate
    end
  end

  devise_for :users
  patch 'current_user/set_current_user_locale', as: 'set_current_user_locale'

  root to: 'home#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
