Rails.application.routes.draw do
  resources :comments, only: [:index, :create, :update, :destroy] do
    member do
      put :resolve
    end
  end
  resources :contents, only: :update
  resources :sections
  resources :protocols

  devise_for :users
  patch 'current_user/set_current_user_locale', as: 'set_current_user_locale'

  root to: 'home#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
