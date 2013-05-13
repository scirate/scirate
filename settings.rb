module Settings
  # Definable application-wide settings which can be
  # overrided by either a local_settings.rb file or values
  # of ENV (in that order). Intended to separate Scirate
  # settings (some of which are sensitive) from general Rails 
  # configuration.
  

  # Modern feed names which arxiv will provide in rss form 
  # as per message at http://export.arxiv.org/rss/doesnotexist
  CURRENT_FEEDS = ['astro-ph', 'cond-mat', 'cs', 'gr-qc', 'hep-ex', 'hep-lat', 'hep-ph', 'hep-th', 'math', 'math-ph', 'nlin', 'nucl-ex', 'nucl-th', 'physics', 'q-bio', 'q-fin', 'quant-ph', 'stat']

  # Rails secret token for signing cookies, should be in ENV for production
  if ENV['RAILS_ENV'] != 'production'
    SECRET_TOKEN = '4b4d948fe0bdde9d1f66af4bcbe15cec68339f7445038032f5313e2f00c36eacb2c8b780fe40e5e9106c9ecbc175893a579f9d138942195eb3fe76e51a767ebe'
  end


  #####
  # Sensitive development settings
  # Define in local_settings.rb
  #####

  # Gmail auth details used in development to test UserMailer mail
  GMAIL_SMTP_USER = ''
  GMAIL_SMTP_PASSWORD = ''


  #####
  # Sensitive production settings
  # Define in Heroku ENV config
  #####

  # Sendgrid auth details used in production to send UserMailer mail
  # SENDGRID_USERNAME = ''
  # SENDGRID_PASSWORD = ''
  
  # New Relic app monitoring auth details
  # NEW_RELIC_LICENSE_KEY = ''
  # NEW_RELIC_APP_NAME = ''


  def self.override(key, val)
    Settings.send(:remove_const, key) if Settings.const_defined?(key, false)
    Settings.const_set(key, val)
  end
end

begin
  require File.expand_path('../local_settings', __FILE__)

  # To override settings for development purposes, make
  # a local_settings.rb file which looks like this:
  #
  # module LocalSettings
  #   SOME_SETTING = 'foo'
  # end

  LocalSettings.constants.each do |key|
    Settings.override(key, LocalSettings.const_get(key))
  end
rescue LoadError # Don't worry if there's no local_settings.rb file
end

ENV.each do |key, val|
  begin
    Settings.override(key, val)
  rescue NameError # Ruby constants have a stricter syntax than ENV
  end
end
