require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'net/http'
require 'font-awesome-rails'
require "sprockets/railtie"


if defined?(Bundler)
  ActiveSupport::Deprecation.silence do
    Bundler.require(:default, Rails.env)
  end
end


module SciRate
  class Application < Rails::Application
    # HACK
    def self.notify_error(exception, message = nil)
      if exception.is_a?(String)
        exception = RuntimeError.new(exception)
      end
      exception = exception.with_details(message) if message
      puts exception.inspect
      puts exception.backtrace.join("\n") if exception.backtrace
      if Rails.env == 'production'
        ExceptionNotifier.notify_exception(exception)
      end
    end

    config.hosts = "localhost"

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    config.action_controller.permit_all_parameters = true
    config.log_level = :info
    config.assets.enabled = true


    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de


    config.assets.paths << Rails.root.join('app', 'assets', 'flash')
    config.assets.paths << Rails.root.join('vendor', 'assets', 'fonts')

    config.action_mailer.default_url_options = { :host => Settings::HOST }

    config.active_job.queue_adapter = :delayed_job
  end
end
