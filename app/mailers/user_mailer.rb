class UserMailer < ActionMailer::Base
  default :from => "no-reply@scirate.com"

  def signup_notification
    @name = "Bill Rosgen"
    mail to: 'rosgen@gmail.com', subject: "Welcome to Scirate!"
  end
end
