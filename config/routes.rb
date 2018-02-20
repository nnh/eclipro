Rails.application.routes.draw do
  # resources :sections
  resources :protocols do
    resources :reference_docxes, only: %i[create show update destroy]
    resources :participations, except: %i[index show]

    resources :contents, only: %i[show update] do
      resources :images, only: %i[create show]

      member do
        get :history, :compare, :revert
        put :change_status
      end

      resources :comments, only: %i[index create] do
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
