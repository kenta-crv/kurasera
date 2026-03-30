# config/routes.rb
Rails.application.routes.draw do
  # ================================================================
  # 1. 共通基盤設定
  # ================================================================
  
  # 管理者認証 (admins)
  devise_for :admins, controllers: {
    sessions: 'admins/sessions',
    registrations: 'admins/registrations'
  }

  # Sidekiq 管理画面
  require 'sidekiq/web'
  authenticate :admin do 
    mount Sidekiq::Web, at: "/sidekiq"
  end

  # コラム基本管理機能
  post 'columns/generate_from_selected', to: 'columns#generate_from_selected', as: :generate_from_selected_columns_fix
  post 'columns/bulk_update_drafts', to: 'columns#bulk_update_drafts', as: :bulk_update_drafts_columns_fix

  resources :columns do
    collection do
      get :draft
      post :generate_gemini
      post :generate_pillar
      post :generate_from_selected
      match 'bulk_update_drafts', via: [:post, :patch]
    end
    member do
      post :generate_from_pillar
      patch :approve
    end
  end

  # ================================================================
  # 2. j-work.jp 向け簡易ルーティング（Host constraints を削除）
  # ================================================================
  
  # トップページ
  root to: 'tops#index'

  # 各ページ
  get 'cleaning',      to: 'tops#cleaning'
  get 'daily',         to: 'tops#daily'
  get 'housekeeping',  to: 'tops#housekeeping'
  get 'cargo',         to: 'tops#cargo'
  get 'logistics',     to: 'tops#logistics'
  get 'event',         to: 'tops#event'

  # columns ページ
  scope ':genre/columns', constraints: { genre: /cargo|cleaning|logistics|event|housekeeping|babysitter/ } do
    get '/',    to: 'columns#index', as: :columns_index
    get '/:id', to: 'columns#show',  as: :columns_show
  end

  # ユーザー関連ページなど
  get 'users', to: 'users#index'

  # ================================================================
  # 3. okey.work や他ドメイン固有ページもシンプルに
  # ================================================================
  
  # マスタードメイン (okey.work)
  get 'construction', to: 'tops#construction'
  get 'security',     to: 'tops#security'
  get 'short',        to: 'tops#short'
  get 'vender',       to: 'tops#vender'
  get 'recruit',      to: 'tops#recruit'
  get 'bpo',          to: 'tops#bpo'
  get 'pest',         to: 'tops#pest'
  get 'ads',          to: 'tops#ads'

  get ':genre/columns',     to: 'columns#index', as: :nested_columns
  get ':genre/columns/:id', to: 'columns#show',  as: :nested_column

  # ri-plus.jp 用ページ
  get 'app', to: 'tops#app', as: :app_root

  # 自販機.net 用ページ
  get 'vender', to: 'tops#vender', as: :vender_root

  # ================================================================
  # 4. 共通の付随機能
  # ================================================================
  get 'draft/progress', to: 'draft#progress', as: :draft_progress
  resources :contracts
end