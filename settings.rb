module Settings
  # Definable application-wide settings which can be
  # overrided by either a local_settings.rb file or values
  # of ENV (in that order). Intended to separate SciRate
  # settings (some of which are sensitive) from general Rails 
  # configuration.
  

  # An ordered list of the top-level arxiv categories which may or may not be parents 
  # to other categories. Used for the sidebar, search etc
  ARXIV_FOLDERS = ['astro-ph', 'cond-mat', 'gr-qc', 'hep-ex', 'hep-lat', 'hep-ph', 'hep-th', 'math-ph', 'nlin', 'nucl-ex', 'nucl-th', 'physics', 'quant-ph', 'math', 'cs', 'q-bio', 'q-fin', 'stat']

  # Rails secret token for signing cookies, should be in ENV for production
  if ENV['RAILS_ENV'] != 'production'
    SECRET_KEY_BASE = '027d35bd099187fe704c6cb189fced29f1562ff46397d77c8e6cfc3e2e66667b98ecb61fa0809807b80934fde0ac4b874ac6c6a3a78e3dcd8e0d906288d1306f'
    SECRET_TOKEN = '4b4d948fe0bdde9d1f66af4bcbe15cec68339f7445038032f5313e2f00c36eacb2c8b780fe40e5e9106c9ecbc175893a579f9d138942195eb3fe76e51a767ebe'
  end

  # Hostname to put in emails and such
  HOST = "scirate.com"


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
