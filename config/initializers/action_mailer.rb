if Rails.env.production?
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.raise_delivery_errors = true
  ActionMailer::Base.smtp_settings = {
    :address => "smtp.sendgrid.net",
    :port => "587",
    :domain => Settings::HOST,
    :authentication => :plain,
    :user_name => Settings::SENDGRID_USERNAME,
    :password => Settings::SENDGRID_PASSWORD
  }
  SciRate3::Application.config.action_mailer.default_url_options = { :host => Settings::HOST }
end
