source 'http://rubygems.org'

gem 'rails'
gem 'bcrypt-ruby'
gem 'faker'
gem 'chronic'
gem 'oai'
gem 'pg'
gem 'will_paginate'
gem 'textacular', :require => 'textacular/rails'
gem 'acts_as_votable'
gem 'arxiv', :git => 'git://github.com/mispy/arxiv.git'
gem 'activerecord-import'
gem 'squeel'
gem 'thin'
gem 'ox'

group :development do
  gem 'annotate'
  gem 'rspec-rails'
  gem 'guard-rspec'
  gem 'taps'
  gem 'pry-rails'
  gem 'quiet_assets'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

gem 'jquery-rails'

# Test gems setup for Macintosh OS X
group :test do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'rb-fsevent', :require => false
  gem 'rb-readline'
  gem 'growl'
  gem 'guard-spork'
  gem 'spork'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'launchy'
end

group :production do
  gem 'newrelic_rpm'
end
