Rails.application.routes.draw do
  root 'invoices#index'

  resources :invoices, only: [:index] do
    collection do
      get :upload
      post :process_upload
    end
  end

  # API endpoints
  namespace :api do
    resources :barcodes, only: [:create]
  end
end
