ruby '2.1.0'
source 'http://rubygems.org'

# Rails
gem 'rails', "~> 4.0.0"
gem 'bcrypt-ruby'

# Sends us emails when stuff breaks in production
gem 'exception_notification',
    git: 'git://github.com/sunkencity/exception_notification'

# Database stuff
gem 'pg' # Postgres support
gem 'squeel' # XXX (Mispy): Can we remove this?
gem 'activerecord-import' # For bulk importing papers
gem 'acts_as_votable' # Comment votes (not scites)
gem 'unidecoder', "~> 1.1.2" # For making ascii author searchterms

# Frontend stuff
gem 'will_paginate' # Displaying pages of results
gem 'chronic' # Natural language date parsing

# For interfacing with the arxiv OAI to
# download new papers in bulk
# arxivsync is our custom gem and can be found at:
# https://github.com/mispy/arxivsync
gem 'oai', git: 'git://github.com/code4lib/ruby-oai'
gem 'arxivsync', git: 'git://github.com/mispy/arxivsync'
gem 'nokogiri', "= 1.5.9"

# Sphinx full-text search support
# Requires mysql gem even though we're using postgres
gem 'mysql2'
gem 'thinking-sphinx'

# Asset preprocessors
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'jquery-rails'
gem 'haml'
gem 'slim'
gem 'ractive-rails'

# SCSS mixins for CSS3 browser compatibility
gem 'bourbon'

group :development, :test do
  gem 'rspec-rails'
  gem 'rspec-rerun'
end

group :development do
  # Development webserver
  gem 'thin'

  # When run, the 'annotate' command will
  # reflect the database schema into helpful
  # comments in the model code
  gem 'annotate'

  # An improved IRB alternative for rails console
  gem 'pry'
  gem 'pry-rails'

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

  # So we can truncate the database properly
  # before each test suite is run
  gem 'database_cleaner'

  # OS X specific?
  gem 'rb-fsevent', :require => false
  gem 'rb-readline'
end

group :production do
  # XXX (Mispy): Not sure we're using this atm
  gem 'newrelic_rpm'
end
