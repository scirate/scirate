require 'sessions_helper'

SciRate::Application.routes.draw do
  root 'feeds#index'

  get '/search', to: 'papers#search', as: 'papers_search'

  post '/api/scite/:paper_uid', to: 'api#scite',
       as: :scite, paper_uid: /.+/
  post '/api/unscite/:paper_uid', to: 'api#unscite',
       as: :unscite, paper_uid: /.+/
  post '/api/subscribe/:feed_uid', to: 'api#subscribe',
       as: :subscribe, feed_uid: /.+/
  post '/api/unsubscribe/:feed_uid', to: 'api#unsubscribe',
       as: :unsubscribe, feed_uid: /.+/
  post '/api/hide_from_recent/:comment_id', to: 'api#hide_from_recent',
       as: :hide_from_recent
  post '/api/settings', to: 'api#settings'

  post '/api/resend_confirm', to: 'api#resend_confirm', as: :resend_confirm
  post '/api/create_stripe_checkout', to: 'api#create_stripe_checkout'

  resources :comments do
    member do
      post :edit
      post :delete
      post :restore
      post :upvote
      post :unvote
      post :report
      post :unreport
      post :reply
    end
  end
  get '/comments', to: 'comments#index'
  get '/comments/:id/history', to: 'comments#history', as: 'comment_history'

  get '/auth/:provider/callback', to: 'sessions#omniauth_callback'
  get '/auth/:provider/disconnect',
    to: 'sessions#omniauth_disconnect', as: 'omniauth_disconnect'
  get '/auth/failure', to: 'sessions#omniauth_failure', as: 'omniauth_failure'
  post '/auth/create', to: 'sessions#omniauth_create', as: 'omniauth_create'

  get '/signup',   to: 'users#new', as: 'signup'
  post '/signup',  to: 'users#create'
  get '/login',    to: 'sessions#new'
  post '/login',   to: 'sessions#create'
  get '/logout',   to: 'sessions#destroy'
  get '/signin',   to: redirect('/login')
  get '/signout',  to: redirect('/logout')

  get '/about',    to: 'static_pages#about'
  get '/conduct',  to: 'static_pages#conduct'
  get '/legal',    to: 'static_pages#legal'
  get '/moderation',    to: 'static_pages#moderation'


  if Settings::JOBS_VISIBLE
    get '/jobs/success', to: 'static_pages#job_success'
    get '/jobs/submit',  to: 'static_pages#submit_job'
    get '/jobs/about',   to: 'static_pages#about_jobs'

    get '/jobs', to: 'static_pages#list_jobs'
  end

  get '/reset_password', to: 'password_resets#new', as: :reset_password
  post '/reset_password', to: 'password_resets#create'

  get '/reset_password/:id', to: 'password_resets#confirm', as: :reset_password_confirm
  post '/reset_password/:id', to: 'password_resets#submit'

  get '/settings', to: 'users#settings'
  post '/settings', to: 'users#settings'

  get '/settings/password', to: 'users#settings_password'
  post '/settings/password', to: 'users#settings_password'

  #resources :users, only: [:new, :create, :edit, :update, :destroy, :admin]
  get '/users/:id/subscriptions', to: 'users#subscriptions', as: 'subscriptions_user'
  get '/users/:id/activate/:confirmation_token', to: 'users#activate', as: 'activate_user'
  get '/feeds', to: 'users#feeds', as: 'feeds'

  get '/arxiv/:paper_uid/scites', to: 'papers#scites', paper_uid: /(.+\/.+|\d+.\d+)(v\d)?/, as: 'paper_scites'
  get '/arxiv/:feed/comments', to: 'comments#index', feed: /.+/, as: 'feed_comments'
  get '/arxiv/*paper_uid', to: 'papers#show', paper_uid: /.+\/.+|\d+.\d+(v\d)?/, as: 'paper'
  get '/arxiv/:feed', to: 'feeds#show', feed: /.+/, as: 'feed'#, constraints: NeedsUserConstraint

  get '/admin', to: 'admin/base#index', as: 'admin'
  post '/admin/alert', to: 'admin/base#alert', as: 'admin_alert'

  get '/admin/users/:username/edit', to: 'admin/users#edit', as: 'admin_edit_user'
  post '/admin/users/:username/update', to: 'admin/users#update', as: 'admin_update_user'
  post '/admin/users/:username/become', to: 'admin/users#become', as: 'admin_become_user'

  get '/:username/download_scites', to: 'users#download_scites', username: /.+/, as: 'user_download_scites'
  get '/:username/scites', to: 'users#scites', username: /.+/, as: 'user_scites'
  get '/:username/comments', to: 'users#comments', username: /.+/, as: 'user_comments'
  get '/:username/papers', to: 'users#papers', username: /.+/, as: 'user_papers'
  get '/:username', to: 'users#activity', username: /.+/, as: 'user'
end
