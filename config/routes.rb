Rails.application.routes.draw do
  # ================================================================
  # 1. 共通基盤設定
  # ================================================================

  devise_for :admins, controllers: {
    sessions: 'admins/sessions',
    registrations: 'admins/registrations'
  }

  devise_for :clients

  require 'sidekiq/web'
  authenticate :admin do
    mount Sidekiq::Web, at: "/sidekiq"
  end

  # ================================================================
  # 2. ルート構造
  # ================================================================

  root to: 'pages#index'

  get 'baby',         to: 'pages#baby'
  get 'babysitter',   to: 'pages#babysitter'
  get 'housekeeping', to: 'pages#housekeeping'

  resources :contracts
end
