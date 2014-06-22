# Code coverage for Travis
require 'coveralls'
Coveralls.wear!

# OmniAuth test mode
require 'omniauth'
OmniAuth.config.test_mode = true

require 'capybara/rspec'

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

Delayed::Worker.delay_jobs = false

# http://stackoverflow.com/questions/8774227/why-not-use-shared-activerecord-connections-for-rspec-selenium
class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || retrieve_connection
  end
end

ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

Capybara.javascript_driver = :webkit

RSpec.configure do |config|
  config.include Capybara::DSL
  config.include Capybara::RSpecMatchers

  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  config.before(:each) do
    reset_email
  end

  # Ensure database is cleaned properly
  config.before(:suite) do
    Search.drop
    Search.migrate
    DatabaseCleaner.clean_with(:truncation)
    load "#{Rails.root}/db/seeds.rb"
  end
end
