namespace :api do
  get "docs", to: "docs#index"
  get "openapi", to: "docs#openapi"

  resource :session, only: [:create, :destroy]
  resources :users, only: [:create]

  resources :proposals, only: [:index, :show, :create, :update] do
    post :vote, on: :member
  end
end
