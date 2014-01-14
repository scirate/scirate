SciRate3::Application.routes.draw do
  root to: 'feeds#index'

  get '/search', to: 'papers#search', as: 'papers_search'

  match '/api/scite/:paper_id', to: 'api#scite', via: [:get, :post], as: :scite
  match '/api/unscite/:paper_id', to: 'api#unscite', via: [:get, :post], as: :unscite
  match '/api/subscribe/:feed_id', to: 'api#subscribe', via: [:get, :post], as: :subscribe
  match '/api/unsubscribe/:feed_id', to: 'api#unsubscribe', via: [:get, :post], as: :unsubscribe
  match '/api/settings', to: 'api#settings', via: [:get, :post]

  post '/api/resend_confirm', to: 'api#resend_confirm', as: :resend_confirm

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
  get '/comments', to: 'comments#index'

  get '/signup',   to: 'users#new', as: 'signup'
  post '/signup',  to: 'users#create'
  get '/login',    to: 'sessions#new'
  get '/logout',   to: 'sessions#destroy'
  get '/about',    to: 'static_pages#about'

  get '/signin',   to: redirect('/login')
  get '/signout',  to: redirect('/logout')

  get '/reset_password', to: 'password_resets#new', as: :reset_password
  post '/reset_password', to: 'password_resets#create'

  get '/reset_password/:id', to: 'password_resets#confirm', as: :reset_password_confirm
  post '/reset_password/:id', to: 'password_resets#submit'

  get '/settings', to: 'users#settings'
  post '/settings', to: 'users#settings'

  get '/settings/password', to: 'users#settings_password'
  post '/settings/password', to: 'users#settings_password'



  resources :sessions, only: [:new, :create, :destroy]
  #resources :users, only: [:new, :create, :edit, :update, :destroy, :admin]
  get '/users/:id/scites', to: 'users#scited_papers', as: 'scites_user'
  get '/users/:id/comments', to: 'users#comments', as: 'comments_user'
  get '/users/:id/subscriptions', to: 'users#subscriptions', as: 'subscriptions_user'
  get '/users/:id/activate/:confirmation_token', to: 'users#activate', as: 'activate_user'

  get '/arxiv/:id/scites', to: 'papers#scites', id: /.+\/.+|\d+.\d+/, as: 'paper_scites'
  get '/arxiv/:id', to: 'papers#show', id: /.+\/.+|\d+.\d+/, as: 'paper'
  get '/arxiv/:feed', to: 'feeds#show', feed: /.+/, as: 'feed'

  get '/admin/users/:username', to: 'users#edit', as: 'edit_user'
  post '/admin/users/:username', to: 'users#update'
  get '/:username', to: 'users#show', username: /.+/, as: 'user'


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   get 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   get 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
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
  # get ':controller(/:action(/:id))(.:format)'
end
