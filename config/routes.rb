Rails.application.routes.draw do
  # Deviseの管理者認証
  devise_for :admins, controllers: {
    sessions: 'admins/sessions',
    registrations: 'admins/registrations'
  }

    # Devise routes for Users
  devise_for :clients, controllers: {
    sessions: "clients/sessions",
    registrations: "clients/registrations",
    passwords: "clients/passwords"
  }

  resources :clients do
    # Campaigns nested under clients
    #resources :campaigns do
    #  get :confirm_payment, on: :member, as: :confirm_payment
    #end
#
    # Push subscriptions
    resources :push_subscriptions, only: [:index, :create]
  end

  
  root to: 'tops#index'

  # --- 各ジャンルLPの定義 ---
  get 'cargo', to: 'tops#cargo'
  get 'security', to: 'tops#security'
  get 'construction', to: 'tops#construction'
  get 'cleaning', to: 'tops#cleaning'
  get 'event', to: 'tops#event'
  get 'vender', to: 'tops#vender'
  get 'logistics', to: 'tops#logistics'
  get 'short', to: 'tops#short'
  get 'recruit', to: 'tops#recruit'
  get 'app', to: 'tops#app'
  get 'ads', to: 'tops#ads'
  get 'bpo', to: 'tops#bpo'
  get 'pest', to: 'tops#pest'

  # --- SEO用: ジャンル別コラム階層 (/genre/columns/:code) ---
  scope ':genre', constraints: { genre: /cargo|security|cleaning|construction|pest/ } do
    resources :columns, only: [:index, :show], as: :nested_columns
  end

  get 'draft/progress', to: 'draft#progress'

  resources :contracts

  # --- 【重要修正】一括処理ルーティングを resources より上に定義 ---
  # これにより /columns/generate_from_selected が ID 検索 (/:id) より先にマッチします
  post 'columns/generate_from_selected', to: 'columns#generate_from_selected', as: :generate_from_selected_columns_fix
  post 'columns/bulk_update_drafts', to: 'columns#bulk_update_drafts', as: :bulk_update_drafts_columns_fix

  # --- 管理機能・汎用リソースとしてのコラム ---
  resources :columns do
    collection do
      get :draft            # ドラフト一覧
      post :generate_gemini # Gemini生成ボタンのPOST
      post :generate_pillar # 親専用生成ボタン
      # 以下の定義は resources 内部だと優先順位が低いため、上記の外出し定義が優先されます
      post :generate_from_selected
      match 'bulk_update_drafts', via: [:post, :patch]
    end
    member do
      post :generate_from_pillar
      patch :approve
    end
  end

  # --- Sidekiq Web UI ---
  require 'sidekiq/web'
  authenticate :admin do 
    mount Sidekiq::Web, at: "/sidekiq"
  end

  #Payment
  get 'checkout/confirmation', to: 'checkout#confirmation', as: :checkout_confirmation
  post 'checkout/create', to: 'checkout#create', as: :checkout_create
  get 'checkout/success', to: 'checkout#success', as: :checkout_success
  get 'checkout/cancel', to: 'checkout#cancel', as: :checkout_cancel

  get 'plans', to: 'plans#index', as: :plans
  post 'plans/select', to: 'plans#select', as: :select_plan

  get 'client/subscription', to: 'client/subscriptions#show', as: :client_subscription
  patch 'client/subscription', to: 'client/subscriptions#update'
  post 'client/subscription/cancel', to: 'client/subscriptions#cancel', as: :cancel_client_subscription
end