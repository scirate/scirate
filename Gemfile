ruby '2.6.9'
source 'https://rubygems.org'

# Rails
gem 'rails', '6.1.0'
gem 'bcrypt', '~> 3.1.7'

gem 'stripe'
gem 'jwt'

# Database stuff
# gem 'pg' # Postgres support
gem 'pg', '~> 1.1'
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
gem 'omniauth-rails_csrf_protection'

# For interfacing with the arxiv OAI to
# download new papers in bulk
# arxivsync is our custom gem and can be found at:
# https://github.com/scirate/arxivsync
gem 'oai', github: 'scirate/ruby-oai'
gem 'arxivsync', github: 'scirate/arxivsync'
gem "nokogiri", ">= 1.13.4"


# Elasticsearch API gem
gem 'elasticsearch'

# Asset preprocessors
gem 'sass-rails'
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

# Frontend stuff
gem 'font-awesome-rails'
gem 'bootstrap-sass', '3.4.1'

group :development, :test do
  gem 'colorize'
  gem 'rspec-rails'
  gem 'rails-controller-testing'

  # An improved IRB alternative for rails console
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
end

group :development do
  # Development webserver
  gem 'thin'

  # When run, the 'annotate' command will
  # reflect the database schema into helpful
  # comments in the model code
  gem 'annotate'

  # Suppresses annoying asset pipeline logs
  # gem 'quiet_assets'

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
  gem 'puma', ">= 5.6.4"
end
