require 'sidekiq/web'
Rails.application.routes.draw do

  get 'sitemap.xml', :to => 'sitemap#index', :defaults => {:format => 'xml'}

  devise_for :recruiters
  get 'pages/about'

  mount Sidekiq::Web => '/sidekiq'

  resources :job_links

  get 'thank-you' => "job_links#info_page"

  resources :job_applications
  devise_for :users, controllers: { registrations: 'users/registrations', omniauth_callbacks: "users/omniauth_callbacks" }


  devise_scope :user do
    get 'ref' => 'users/registrations#new'
  end

  post 'apply_to_related_searches' => 'pages#apply_to_related_searches'

  root to: "job_links#new"

  get 'about' => 'pages#about', as: :about

  get 'products' => 'pages#price_page', as: :price_page

  get 'add_user_resume_and_phone' => 'pages#add_user_resume_and_phone', as: :resume_and_phone
  patch 'update_user' => 'pages#update_user', as: :update_user
  patch 'add_2_credits' => 'pages#add_2_credits', as: :add_2_credits_path

  get 'share' => 'pages#sharing', as: :share

  get 'profile' => 'pages#profile', as: :profile

  get 'mission' => 'pages#mission', as: :mission

  get 'loading' => 'pages#loading', as: :loading

  get 'import_success' => 'pages#import_success', as: :import_success

  get 'job_links/edit_user_info/:id' => 'job_links#edit_user_info', as: :edit_user_info

  get 'is_still_loading' => 'job_links#is_still_loading', as: :still_loading_json


  resources :charges
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
