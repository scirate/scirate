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

  def password_change(user)
    @user = user
    mail :to => user.email, :subject => "Your Scirate password has been changed"
  end

  def email_change(user, old_email)
    @user = user
    @old_email = old_email

    mail to: old_email, subject: "Your email address has been changed"
  end
end
