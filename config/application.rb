require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'net/http'
require 'exception_notifier'

if defined?(Bundler)
  ActiveSupport::Deprecation.silence do
    Bundler.require(:default, Rails.env)
  end
end

class Exception
  # From http://stackoverflow.com/questions/2823748/how-do-i-add-information-to-an-exception-message-without-changing-its-class-in-r
  def with_details(extra)
    begin
      raise self, "#{message} - #{extra}", backtrace
    rescue Exception => e
      return e
    end
  end
end

module SciRate3
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    # config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.assets.initialize_on_precompile = false

    config.action_mailer.default_url_options = { :host => Settings::HOST }

    config.cache_store = :memory_store
  end

  SciRate3::Application.config.middleware.use ::ExceptionNotifier,
    email_prefix: "[SciRate Error] ",
    sender_address: "notifier@scirate.com",
    exception_recipients: %w{scirate@mispy.me}

  class << self
    def notify_error(exception, message=nil)
      if exception.is_a?(String)
        exception = RuntimeError.new(exception)
      end
      exception = exception.with_details(message) if message
      puts exception.inspect
      puts exception.backtrace.join("\n") if exception.backtrace
      if Rails.env == "production"
        ::ExceptionNotifier::Notifier.background_exception_notification(exception)
      end
    end
  end
end
