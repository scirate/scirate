class UserMailer < ActionMailer::Base
  default from: "SciRate <notifications@#{Settings::HOST}>"

  def mail(*args)
    super
  end

  def signup_confirmation(user)
    @user = user
    mail to: user.email, subject: "Welcome to SciRate!"
  end

  def password_reset(user)
    @user = user
    mail :to => user.email, :subject => "Password Reset"
  end

  def password_change(user)
    @user = user
    mail :to => user.email, :subject => "Your SciRate password has been changed"
  end

  def email_change(user, old_email)
    @user = user
    @old_email = old_email

    mail to: old_email, subject: "Your email address has been changed"
  end

  def comment_alert(user, comment)
    @user = user
    @comment = comment

    mail from: "#{comment.user.fullname} <notifications@scirate.com>", to: user.email, subject: "[SciRate] Re: #{comment.paper.title}"
  end
end
