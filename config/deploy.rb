# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, 'scirate'
set :repo_url, 'https://github.com/draftable/scirate3.git'
set :deploy_via, :remote_cache

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/scirate'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
set :default_env, { 
  RAILS_ENV: 'production',
  RAILS_GROUPS: 'assets'
}

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  task :setup do
    on roles(:app), in: :parallel do
      within release_path do
        execute :ln, '-sf /home/scirate/database.yml config/database.yml'
        execute :ln, '-sf /home/scirate/local_settings.rb local_settings.rb'

        execute :bundle, 'install'
        execute :rake, 'assets:clean'
        execute :rake, 'assets:precompile'
      end
    end

    on roles(:app) do
      within release_path do
        execute :rake, 'db:migrate'
      end
    end

    on roles(:app), in: :parallel do
      within release_path do
        execute :sudo, 'service unicorn restart'
        execute :rake, 'cache:clear'
      end
    end
  end

  after :publishing, :setup
end
