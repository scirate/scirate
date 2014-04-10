# config/puma.rb

environment "production"
port 8000

threads 8,32
workers 3
preload_app!

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end
