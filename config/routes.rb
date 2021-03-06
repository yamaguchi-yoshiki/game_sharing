Rails.application.routes.draw do
  devise_for :admin, skip: [:registrations, :passwords] ,controllers: {
    sessions: "admin/sessions"
  }

  devise_for :customers,skip: [:passwords], controllers: {
    registrations: "public/registrations",
    sessions: 'public/sessions'
  }

  devise_scope :customer do
    post 'users/guest_sign_in', to: 'users/sessions#guest_sign_in'
  end

  namespace :admin do
    # homes
    root to: 'homes#top'
    # 機種関連
    resources :platforms, only: [:index, :create, :edit, :update]
    # タグ関連
    resources :tags, only: [:index, :destroy]
  end

  scope module: :public do
    # homes
    root to: 'homes#top'
    get '/about' => 'homes#about', as: 'about'
    # 会員関連
    resource :customers, only: [] do
      get '/quit_check' => 'customers#quit_check'
      patch '/withdraw' => 'customers#withdraw'
    end
    resources :customers, only: [:show, :edit, :update] do
      # 会員ごとの一覧ページ
      resources :reviews, only: [:index]
      resources :thread_messages, only: [:index]
    end
    # ゲーム関連
    get "games/search"=>"games#search"
    resources :games do
      resources :reviews, only: [:new]
      resources :threads, only: [:index, :new]
    end
    # 機種ごとのゲーム一覧ページ
    get "rankings/search"=>"rankings#search"
    resources :rankings, only: [:index]
    # レビュー関連
    resources :reviews, only: [:show, :create, :edit, :update, :destroy] do
      resource :sympathies, only: [:create, :destroy]
      resources :review_comments, only: [:create, :destroy]
    end
    # スレッド関連
    resources :threads, only: [:show, :create, :destroy] do
      resources :thread_messages, only: [:create, :destroy]
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
