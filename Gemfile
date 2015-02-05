ruby '2.1.4'
source 'http://rubygems.org'

# Rails
gem 'rails', '4.1.9'
gem 'bcrypt', '~> 3.1.7'

# Database stuff
gem 'pg' # Postgres support
gem 'activerecord-import' # For bulk importing papers
gem 'acts_as_votable' # Comment votes (not scites)
gem 'unidecoder', '~> 1.1.2' # For making ascii author searchterms

# Ruby futures
#gem 'futuroscope', require: 'futuroscope/convenience'

# Frontend stuff
gem 'will_paginate' # Displaying pages of results
gem 'chronic' # Natural language date parsing
gem 'turbolinks' # Speeds up links

# Authentication
gem 'omniauth' # For google
gem 'omniauth-google-oauth2'

# For interfacing with the arxiv OAI to
# download new papers in bulk
# arxivsync is our custom gem and can be found at:
# https://github.com/mispy/arxivsync
gem 'oai', github: 'mispy/ruby-oai' # For Rails 4.1 compatibility
gem 'arxivsync', github: 'mispy/arxivsync'
gem 'nokogiri', '1.5.9'

# Elasticsearch API gem
gem 'stretcher'
gem 'faraday', '0.8.9' # 0.9.0 breaks faraday_middleware-multi_json

# Asset preprocessors
gem 'sass-rails', '4.0.3'
gem 'coffee-rails'
gem 'uglifier'
gem 'jquery-rails'
gem 'slim'

# Memcached gem
gem 'dalli'

# SCSS mixins for CSS3 browser compatibility
gem 'bourbon'

# Delayed job for async tasks (email)
gem 'delayed_job_active_record'
gem 'daemons'

group :development, :test do
  gem 'rspec-rails', '~> 2.9'

  # An improved IRB alternative for rails console
  gem 'pry'
  gem 'pry-rails'
end

group :production, :profile do
  gem 'newrelic_rpm'
end

group :development do
  # Development webserver
  gem 'thin'

  # When run, the 'annotate' command will
  # reflect the database schema into helpful
  # comments in the model code
  gem 'annotate'

  # Suppresses annoying asset pipeline logs
  gem 'quiet_assets'

  # Rails application preloader
  # Speeds up rake/rspec startup
  # You need to use the binstubs in scirate/bin
  gem 'spring'
  gem 'spring-commands-rspec'

  # For dumping feeds to seeds.rb to test with
  gem 'seed_dump'
end

group :test do
  # Factory girl creates valid models
  # as needed for use in tests
  gem 'factory_girl_rails'

  # Capybara is used to mimic a simple
  # browser for integration tests
  gem 'capybara'

  # Extensions to rspec syntax
  gem 'shoulda-matchers'

  # So we can truncate the database properly
  # before each test suite is run
  gem 'database_cleaner'

  # Code coverage
  gem 'coveralls', require: false

  # Javascript testing
  gem 'capybara-webkit'

  # Manipulating time during tests
  gem 'timecop'
end

group :profile do
  gem 'stackprof'
  gem 'ruby-prof'
end

group :production do
  # Sends us emails when stuff breaks in production
  gem 'exception_notification'
  gem 'puma'
end
