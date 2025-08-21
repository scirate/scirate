if Rails.env.production?
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.raise_delivery_errors = true
  ActionMailer::Base.smtp_settings = {
    :address => "smtp.mailersend.net",
    :port => "587",
    :domain => Settings::HOST,
    :enable_starttls_auto => true,
    :authentication => :plain,
    :user_name => Settings::MAILERSEND_USERNAME,
    :password => Settings::MAILERSEND_PASSWORD
  }
  SciRate::Application.config.action_mailer.default_url_options = { :host => Settings::HOST }
end
