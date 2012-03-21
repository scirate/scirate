require "spec_helper"

describe UserMailer do
  let(:user) { FactoryGirl.create(:user) }

  describe 'signup confirmation' do
    let(:mail) { UserMailer.signup_notification(user) }
 
    #ensure that the subject is correct
    it 'renders the subject' do
      mail.subject.should == 'Welcome to Scirate!'
    end
  
    #ensure that the sender is correct
    it 'renders the sender email' do
      mail.from.should == ['no-reply@scirate.com']
    end

    #ensure that the body contains the right content
    it 'has the right body content' do
      mail.body.encoded.should match("To activate your account, visit")
    end
 
    #ensure that the receiver is correct
    it 'renders the receiver email' do
       mail.to.should == [user.email]
    end

    #ensure that the @name variable appears in the email body
    it 'assigns @name' do
      mail.body.encoded.should match(user.name)
    end
 
    # #ensure that the @confirmation_url variable appears in the email body
    # it 'assigns @confirmation_url' do
    #   mail.body.encoded.should match("http://aplication_url/#{user.id}/confirmation")
    # end
  end

  describe 'password reset' do
    let(:mail) { UserMailer.password_reset(user) }
 
    before { user.send_password_reset }

    #ensure that the subject is correct
    it 'renders the subject' do
      mail.subject.should == 'Password Reset'
    end
  
    #ensure that the sender is correct
    it 'renders the sender email' do
      mail.from.should == ['no-reply@scirate.com']
    end

    #ensure that the body contains the right content
    it 'has the right body content' do
      mail.body.encoded.should match("To reset your password, click the URL below.")
    end
 
    #ensure that the receiver is correct
    it 'renders the receiver email' do
       mail.to.should == [user.email]
    end

    #ensure that the @name variable appears in the email body
    it 'assigns @name' do
      mail.body.encoded.should match(user.name)
    end
 
    #ensure that right url appears in the email body
    it 'assigns the right url' do
      mail.body.encoded.should match( edit_password_reset_url(user.password_reset_token))
    end
  end
end
