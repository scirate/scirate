class JobMailer < ActionMailer::Base
  default from: "SciRate Jobs <notifications@#{Settings::HOST}>"

  def mail(*args)
    super
  end

  def job_notification(contact_email, contact_name, job_token)
    @contact_name = contact_name
    @url = Settings::HOST + "/jobs/submit?i=" + job_token
    mail to: contact_email, bcc: Settings::SCIRATE_EMAIL_ADMIN, subject: "Job submitted to SciRate!"
  end
end
