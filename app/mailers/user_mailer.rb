class UserMailer < ActionMailer::Base
  default :from => "no-reply@scirate.com"

  def signup_confirmation(user)
    @user = user
    mail to: user.email, subject: "Welcome to Scirate!"
  end

  def password_reset(user)
    @user = user
    mail :to => user.email, :subject => "Password Reset"
  end
end
