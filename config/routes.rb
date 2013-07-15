Scirate3::Application.routes.draw do
  root to: 'papers#index', as: 'papers'
  root to: 'papers#index'

  resources :feeds do
    member do
      post :subscribe
      post :unsubscribe
    end
  end

  get '/search', to: 'papers#search', as: 'papers_search'


  post '/scite', to: 'scites#create'
  post '/unscite', to: 'scites#destroy'

  put '/subscriptions', to: 'subscriptions#update'

  resources :comments do
    member do
      post :edit
      post :upvote
      post :downvote
      post :unvote
      post :report
      post :unreport
      post :reply
    end
  end
  match '/comments', to: 'comments#index'

  match '/signup',   to: 'users#new'
  match '/signin',   to: 'sessions#new'
  match '/signout',  to: 'sessions#destroy'
  match '/about',    to: 'static_pages#about'
  match '/settings', to: 'users#settings'
  match '/settings/password', to: 'users#settings_password'

  resources :sessions, only: [:new, :create, :destroy]
  resources :users, only: [:show, :new, :create, :edit, :update, :destroy, :admin]
  get '/users/:id/scites', to: 'users#scited_papers', as: "scites_user"
  get '/users/:id/comments', to: 'users#comments', as: "comments_user"
  get '/users/:id/subscriptions', to: 'users#subscriptions', as: "subscriptions_user"
  get '/users/:id/activate/:confirmation_token', to: 'users#activate', as: "activate_user"
  resources :password_resets, only: [:new, :create, :edit, :update]

  get '/arxiv/:feed', to: 'feeds#show', feed: /.+/, as: "feed"
  #custom route to use arXiv identifiers as id's for papers
  get '/:id', to: 'papers#show', id: /.+/, as: "paper"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
