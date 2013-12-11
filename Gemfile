ruby '2.0.0'
source 'http://rubygems.org'

gem 'rails'
gem 'bcrypt-ruby', "~> 3.0.0"
gem 'faker'
gem 'chronic'
gem 'oai', :git => 'git://github.com/code4lib/ruby-oai'
gem 'pg'
gem 'will_paginate'
gem 'textacular', :require => 'textacular/rails'
gem 'acts_as_votable', :git => 'git://github.com/ryanto/acts_as_votable'
gem 'activerecord-import'
gem 'squeel'
gem 'thin'
gem 'arxivsync', ">= 0.0.3"
gem 'exception_notification', :git => 'git://github.com/sunkencity/exception_notification'
gem 'acts_as_list'
gem 'haml'
gem 'bourbon'

group :development do
  gem 'annotate'
  gem 'rspec-rails'
  gem 'taps'
  gem 'pry-rails'
  gem 'quiet_assets'

  # Rails application preloader
  # Speeds up rake/rspec startup
  gem 'spring'
  gem 'spring-commands-rspec'
  #gem 'sql-logging'
end

# assets
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'


gem 'jquery-rails'

# Test gems setup for Macintosh OS X
group :test do
  gem 'rspec-rails'
  gem 'rb-fsevent', :require => false
  gem 'rb-readline'
  gem 'growl'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'launchy'

  # Capybara for integration tests
  gem 'capybara'

  # Minitest integration
  gem 'minitest-rails'
  gem 'minitest-rails-capybara'
end

group :production do
  gem 'newrelic_rpm'
end
