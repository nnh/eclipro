Rails.application.routes.draw do
  # resources :sections
  resources :protocols do
    resources :contents, only: :update do
      member do
        get :history, :compare
      end
      resources :comments, only: [:index, :create] do
        member do
          put :resolve
        end
        collection do
          get :comment, :reply
        end
      end
    end
  end

  devise_for :users
  patch 'current_user/set_current_user_locale', as: 'set_current_user_locale'

  root to: 'home#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
